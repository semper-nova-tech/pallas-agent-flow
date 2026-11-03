#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  pallas-quick-herdr.sh start --repo DIR --branch NAME --request TEXT \
    [--base REF] [--model MODEL] [--advisor MODEL]
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

[[ "${1:-}" == start ]] || usage
shift

repo=
branch=
request=
base=
model=sonnet
advisor=
while (($#)); do
  case "$1" in
    --repo) repo="${2:?missing value for --repo}"; shift 2 ;;
    --branch) branch="${2:?missing value for --branch}"; shift 2 ;;
    --request) request="${2:?missing value for --request}"; shift 2 ;;
    --base) base="${2:?missing value for --base}"; shift 2 ;;
    --model) model="${2:?missing value for --model}"; shift 2 ;;
    --advisor) advisor="${2:?missing value for --advisor}"; shift 2 ;;
    *) usage ;;
  esac
done
[[ -n "$repo" && -n "$branch" && -n "$request" ]] || usage

created="$(herdr worktree create --cwd "$repo" --branch "$branch" ${base:+--base "$base"} --no-focus)"
pane="$(jq -r '.result.root_pane.pane_id' <<<"$created")"
worktree_path="$(jq -r '.result.worktree.path' <<<"$created")"

herdr agent start "$branch" --kind claude --pane "$pane" -- \
  --model "$model" ${advisor:+--advisor "$advisor"} >/dev/null
herdr agent prompt "$branch" "/pallas-quick:quick-change $request" >/dev/null

jq -n \
  --arg name "$branch" \
  --arg pane_id "$pane" \
  --arg worktree_path "$worktree_path" \
  --arg model "$model" \
  --arg advisor "$advisor" \
  '{$name, $pane_id, $worktree_path, $model, $advisor}'
