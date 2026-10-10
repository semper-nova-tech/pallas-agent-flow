#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  lore-flow-herdr.sh workspace --cwd DIR --label LABEL
  lore-flow-herdr.sh worker --pane PANE_ID --name NAME --cwd DIR --model MODEL \
    --prompt-file FILE [--run-id ID] [--packet-id ID] [--timeout MS]
  lore-flow-herdr.sh wait --name NAME [--timeout MS]
  lore-flow-herdr.sh close --name NAME
EOF
  exit 2
}

require_command() {
  command -v "$1" >/dev/null || {
    printf 'Required command not found: %s\n' "$1" >&2
    exit 1
  }
}

require_command herdr
require_command jq

command_name="${1:-}"
shift || true

case "$command_name" in
  workspace)
    cwd=
    label=
    while (($#)); do
      case "$1" in
        --cwd) cwd="${2:?missing value for --cwd}"; shift 2 ;;
        --label) label="${2:?missing value for --label}"; shift 2 ;;
        *) usage ;;
      esac
    done
    [[ -n "$cwd" && -n "$label" ]] || usage

    herdr workspace create --cwd "$cwd" --label "$label" --no-focus |
      jq '.result.root_pane | {workspace_id, tab_id, pane_id}'
    ;;

  worker)
    pane=
    name=
    cwd=
    model=
    prompt_file=
    run_id=
    packet_id=
    timeout=
    while (($#)); do
      case "$1" in
        --pane) pane="${2:?missing value for --pane}"; shift 2 ;;
        --name) name="${2:?missing value for --name}"; shift 2 ;;
        --cwd) cwd="${2:?missing value for --cwd}"; shift 2 ;;
        --model) model="${2:?missing value for --model}"; shift 2 ;;
        --prompt-file) prompt_file="${2:?missing value for --prompt-file}"; shift 2 ;;
        --run-id) run_id="${2:?missing value for --run-id}"; shift 2 ;;
        --packet-id) packet_id="${2:?missing value for --packet-id}"; shift 2 ;;
        --timeout) timeout="${2:?missing value for --timeout}"; shift 2 ;;
        *) usage ;;
      esac
    done
    [[ -n "$pane" && -n "$name" && -n "$cwd" && -n "$model" && -f "$prompt_file" ]] || usage

    # Split the largest pane in the tab so repeated workers never shrink one column.
    # Terminal cells are about twice as tall as wide.
    read -r split_pane direction < <(
      herdr pane layout --pane "$pane" | jq -r '.result.layout.panes
        | max_by(.rect.width * .rect.height)
        | "\(.pane_id) \(if .rect.width > 2 * .rect.height then "right" else "down" end)"'
    )
    worker_pane="$(herdr pane split --pane "$split_pane" --direction "$direction" --cwd "$cwd" --no-focus |
      jq -r '.result.pane.pane_id')"
    herdr agent start "$name" --kind cursor --pane "$worker_pane" -- --model "$model" >/dev/null

    # --wait requires an observed state change first, so an idle agent that has not
    # started the prompt yet is never mistaken for a finished one.
    status=failed
    if result="$(herdr agent prompt "$name" "$(<"$prompt_file")" --wait ${timeout:+--timeout "$timeout"})"; then
      status="$(jq -r '.result.agent.agent_status' <<<"$result")"
    fi
    jq -n \
      --arg name "$name" \
      --arg pane_id "$worker_pane" \
      --arg model "$model" \
      --arg run_id "$run_id" \
      --arg packet_id "$packet_id" \
      --arg status "$status" \
      '{$name, $pane_id, $model, $run_id, $packet_id, $status}'
    [[ "$status" == idle || "$status" == done ]]
    ;;

  wait)
    name=
    timeout=
    while (($#)); do
      case "$1" in
        --name) name="${2:?missing value for --name}"; shift 2 ;;
        --timeout) timeout="${2:?missing value for --timeout}"; shift 2 ;;
        *) usage ;;
      esac
    done
    [[ -n "$name" ]] || usage
    herdr agent wait "$name" ${timeout:+--timeout "$timeout"}
    ;;

  close)
    name=
    while (($#)); do
      case "$1" in
        --name) name="${2:?missing value for --name}"; shift 2 ;;
        *) usage ;;
      esac
    done
    [[ -n "$name" ]] || usage
    herdr pane close "$(herdr agent get "$name" | jq -r '.result.agent.pane_id')"
    ;;

  *)
    usage
    ;;
esac
