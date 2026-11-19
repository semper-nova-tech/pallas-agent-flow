#!/usr/bin/env bash
# Per-machine registry, source pull, and report plumbing for the chief-of-staff skill.
# Every subcommand prints JSON unless noted. Nothing here edits a source: no checkout,
# push, pane close (except the watch pane this script opened), or roadmap write.
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  chief.sh home
  chief.sh init
  chief.sh detect
  chief.sh source add --kind git|worktrees|roadmap|linear (--path DIR|FILE | --spec TEXT) [--label TEXT]
  chief.sh source list
  chief.sh source remove ID
  chief.sh pull [--since ISO] [--source ID] [--quiet]
  chief.sh snapshot latest
  chief.sh snapshot since ISO
  chief.sh cursor set [ISO]
  chief.sh report new                 # prints the path for a new brief (text)
  chief.sh report open PATH           # Herdr tab + glow, or a plain fallback
  chief.sh watch start [--interval SECONDS] [--brief-at HH:MM] [--agent NAME] [--plugin-dir DIR]
  chief.sh watch stop
  chief.sh fire-brief [--agent NAME] [--prompt TEXT] [--plugin-dir DIR]
  chief.sh collect ...                # the loop the watch pane runs
EOF
  exit 2
}

require_command() {
  command -v "$1" >/dev/null || {
    printf 'Required command not found: %s\n' "$1" >&2
    exit 1
  }
}
require_command jq

HOME_DIR="${PALLAS_CHIEF_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/pallas-chief-of-staff}"
REGISTRY="$HOME_DIR/registry.json"
TOOLS="$HOME_DIR/tools.json"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

now_iso() { date -u +%Y-%m-%dT%H:%M:%SZ; }
stamp() { date +%Y-%m-%d-%H%M; }

in_herdr() {
  [[ "${HERDR_ENV:-}" == 1 ]] && command -v herdr >/dev/null 2>&1
}

ensure_registry() {
  [[ -f "$REGISTRY" ]] || {
    printf 'No registry at %s. Run: chief.sh init\n' "$REGISTRY" >&2
    exit 1
  }
}

write_registry() {
  # stdin: new registry JSON
  local tmp
  tmp="$(mktemp "$HOME_DIR/.registry.XXXXXX")"
  cat >"$tmp"
  jq . "$tmp" >/dev/null
  mv "$tmp" "$REGISTRY"
}

# ---------------------------------------------------------------- init / detect

cmd_init() {
  mkdir -p "$HOME_DIR/snapshots" "$HOME_DIR/reports"
  if [[ ! -f "$REGISTRY" ]]; then
    jq -n \
      --arg id "$(hostname -s 2>/dev/null || hostname)-$(date +%s)" \
      --arg host "$(hostname)" \
      --arg user "${USER:-$(id -un)}" \
      --arg at "$(now_iso)" \
      --arg script "$SCRIPT_PATH" \
      '{machine: {id: $id, hostname: $host, user: $user, registered_at: $at},
        script_path: $script, sources: [], cursor: {last_brief_at: null}, watch: null}' |
      write_registry
  else
    jq --arg script "$SCRIPT_PATH" '.script_path = $script' "$REGISTRY" | write_registry
  fi
  cat "$REGISTRY"
}

plugin_installed() {
  # $1: plugin name. Claude Code user/project installs, or a Cursor local plugin dir.
  local f="$HOME/.claude/plugins/installed_plugins.json"
  if [[ -f "$f" ]] && jq -e --arg p "$1" '.plugins | keys[] | select(startswith($p + "@"))' "$f" >/dev/null 2>&1; then
    jq -r --arg p "$1" '.plugins | to_entries[] | select(.key | startswith($p + "@")) | .value[0].version' "$f" | head -1
    return 0
  fi
  if [[ -f "$HOME/.cursor/plugins/local/$1/.cursor-plugin/plugin.json" ]]; then
    jq -r .version "$HOME/.cursor/plugins/local/$1/.cursor-plugin/plugin.json"
    return 0
  fi
  if [[ "$1" == pallas-agent-flow && -n "${PALLAS_AGENT_FLOW_HOME:-}" && -f "$PALLAS_AGENT_FLOW_HOME/.claude-plugin/plugin.json" ]]; then
    jq -r .version "$PALLAS_AGENT_FLOW_HOME/.claude-plugin/plugin.json"
    return 0
  fi
  return 1
}

skill_registered() {
  # $1: skill directory name in a personal skills folder.
  [[ -f "$HOME/.claude/skills/$1/SKILL.md" || -f "$HOME/.cursor/skills/$1/SKILL.md" || -f "$HOME/.agents/skills/$1/SKILL.md" ]]
}

tool_json() {
  # $1 name, $2 path or empty, $3 version or empty, $4 extra JSON object
  jq -n --arg name "$1" --arg path "$2" --arg version "$3" --argjson extra "${4:-{\}}" \
    '{name: $name, available: ($path != ""), path: (if $path == "" then null else $path end),
      version: (if $version == "" then null else $version end)} + $extra'
}

cmd_detect() {
  mkdir -p "$HOME_DIR"
  local herdr_path herdr_ver skema_path skema_ver gh_path gh_auth glow_path paf pq
  herdr_path="$(command -v herdr || true)"
  herdr_ver=""; [[ -n "$herdr_path" ]] && herdr_ver="$(herdr --version 2>/dev/null | head -1 || true)"
  skema_path="$(command -v skema || true)"; [[ -z "$skema_path" && -x "$HOME/.local/bin/skema" ]] && skema_path="$HOME/.local/bin/skema"
  skema_ver=""; [[ -n "$skema_path" ]] && skema_ver="$("$skema_path" --version 2>/dev/null | head -1 || true)"
  gh_path="$(command -v gh || true)"
  gh_auth=false; [[ -n "$gh_path" ]] && gh auth status >/dev/null 2>&1 && gh_auth=true
  glow_path="$(command -v glow || true)"
  paf="$(plugin_installed pallas-agent-flow || true)"
  pq="$(plugin_installed pallas-quick || true)"

  jq -n \
    --arg at "$(now_iso)" \
    --argjson herdr "$(tool_json herdr "$herdr_path" "$herdr_ver" \
      "$(jq -n --argjson inside "$(in_herdr && echo true || echo false)" \
          --argjson skill "$(skill_registered cli-herdr && echo true || echo false)" \
          '{inside_session: $inside, cli_herdr_skill: $skill}')")" \
    --argjson paf "$(jq -n --arg v "$paf" '{name: "pallas-agent-flow", available: ($v != ""), version: (if $v == "" then null else $v end)}')" \
    --argjson pq "$(jq -n --arg v "$pq" '{name: "pallas-quick", available: ($v != ""), version: (if $v == "" then null else $v end)}')" \
    --argjson skema "$(tool_json skema "$skema_path" "$skema_ver" \
      "$(jq -n --argjson skill "$(skill_registered skema-diagram && echo true || echo false)" '{skema_diagram_skill: $skill}')")" \
    --argjson gh "$(tool_json gh "$gh_path" "" "$(jq -n --argjson a "$gh_auth" '{authenticated: $a}')")" \
    --argjson glow "$(tool_json glow "$glow_path" "" '{}')" \
    '{detected_at: $at,
      tools: {herdr: $herdr, pallas_agent_flow: $paf, pallas_quick: $pq, skema: $skema, gh: $gh, glow: $glow,
              linear: {name: "linear", available: null, note: "decided in-session: Linear MCP tools or the linear-api skill"}}}' |
    tee "$TOOLS"
}

# ---------------------------------------------------------------- sources

cmd_source() {
  ensure_registry
  local sub="${1:-}"; shift || true
  case "$sub" in
    add)
      local kind= path= spec= label=
      while (($#)); do
        case "$1" in
          --kind) kind="${2:?}"; shift 2 ;;
          --path) path="${2:?}"; shift 2 ;;
          --spec) spec="${2:?}"; shift 2 ;;
          --label) label="${2:?}"; shift 2 ;;
          *) usage ;;
        esac
      done
      case "$kind" in
        git|worktrees|roadmap)
          [[ -n "$path" ]] || usage
          if [[ -d "$path" ]]; then path="$(cd "$path" && pwd)"; else path="$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"; fi ;;
        linear) [[ -n "$spec" ]] || usage ;;
        *) usage ;;
      esac
      local id
      id="$kind-$(basename "${path:-$spec}" | tr -c 'a-zA-Z0-9\n' '-' | tr 'A-Z' 'a-z' | sed 's/-*$//')"
      jq --arg id "$id" --arg kind "$kind" --arg path "$path" --arg spec "$spec" \
         --arg label "${label:-$(basename "${path:-$spec}")}" --arg at "$(now_iso)" \
        '.sources |= (map(select(.id != $id)) + [{id: $id, kind: $kind,
            path: (if $path == "" then null else $path end),
            spec: (if $spec == "" then null else $spec end), label: $label, added_at: $at}])' \
        "$REGISTRY" | write_registry
      jq --arg id "$id" '.sources[] | select(.id == $id)' "$REGISTRY"
      ;;
    list) jq '.sources' "$REGISTRY" ;;
    remove)
      local id="${1:?source id}"
      jq --arg id "$id" '.sources |= map(select(.id != $id))' "$REGISTRY" | write_registry
      jq '.sources' "$REGISTRY"
      ;;
    *) usage ;;
  esac
}

# ---------------------------------------------------------------- pull

default_branch() {
  local repo="$1" b
  b="$(git -C "$repo" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
  if [[ -z "$b" ]]; then
    for c in main master; do git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/$c" && { b="$c"; break; }; done
  fi
  [[ -n "$b" ]] || b="$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
  printf '%s' "$b"
}

git_worktrees_json() {
  # $1 repo. One object per worktree with dirty count.
  git -C "$1" worktree list --porcelain 2>/dev/null |
    awk -v RS= -v FS='\n' '{p=""; b=""; d="false"; for(i=1;i<=NF;i++){ if($i ~ /^worktree /){p=substr($i,10)} else if($i ~ /^branch /){b=substr($i,8); sub("^refs/heads/","",b)} else if($i=="detached"){d="true"} } print p "\x1f" b "\x1f" d}' |
    while IFS=$'\x1f' read -r p b d; do
      [[ -n "$p" ]] || continue
      local dirty=0
      [[ -d "$p" ]] && dirty="$(git -C "$p" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
      jq -n --arg p "$p" --arg b "$b" --argjson d "$d" --argjson dirty "$dirty" \
        '{path: $p, branch: (if $b == "" then null else $b end), detached: $d, dirty_files: $dirty}'
    done | jq -s .
}

pull_git() {
  # $1 source JSON, $2 since ISO
  local src="$1" since="$2" repo def fetch_ok=true commits branches prs=null review_requested=null gh_note="" sep=$'\x1f'
  repo="$(jq -r .path <<<"$src")"
  [[ -d "$repo/.git" || -f "$repo/.git" ]] || { jq -n --argjson s "$src" '$s + {error: "not a git repository"}'; return; }
  git -C "$repo" fetch --prune --quiet 2>/dev/null || fetch_ok=false
  def="$(default_branch "$repo")"
  commits="$(git -C "$repo" log --remotes --since="$since" --no-merges --format='%h%x1f%an%x1f%aI%x1f%s%x1f%D' 2>/dev/null | head -200 |
    jq -R -s 'split("\n") | map(select(length > 0) | split("\u001f") | {sha: .[0], author: .[1], at: .[2], subject: .[3], refs: .[4]})')"
  branches="$(git -C "$repo" for-each-ref --sort=-committerdate --count=40 refs/remotes/origin --format="%(refname:short)${sep}%(committerdate:iso-strict)${sep}%(authorname)" 2>/dev/null |
    grep -v -E "^origin/(HEAD|$def)${sep}" | while IFS="$sep" read -r ref at who; do
      local ab
      ab="$(git -C "$repo" rev-list --left-right --count "origin/$def...$ref" 2>/dev/null | tr '\t' ' ' || echo "0 0")"
      jq -n --arg ref "${ref#origin/}" --arg at "$at" --arg who "$who" --arg ab "${ab:-0 0}" \
        '($ab | split(" ")) as $c | {branch: $ref, last_commit_at: $at, author: $who, behind: ($c[0] | tonumber), ahead: ($c[1] | tonumber)}'
    done | jq -s .)"
  if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
    prs="$(cd "$repo" && gh pr list --state open --limit 50 \
        --json number,title,headRefName,author,isDraft,reviewDecision,updatedAt,url,statusCheckRollup 2>/dev/null |
      jq 'map({number, title, branch: .headRefName, author: .author.login, draft: .isDraft, review: .reviewDecision,
                updated_at: .updatedAt, url,
                checks: ((.statusCheckRollup // []) | group_by(.conclusion // .status) | map({(.[0].conclusion // .[0].status // "UNKNOWN"): length}) | add // {})})' || echo null)"
    review_requested="$(cd "$repo" && gh pr list --state open --search 'review-requested:@me' --json number 2>/dev/null | jq 'map(.number)' || echo null)"
    [[ -n "$prs" ]] || prs=null
    [[ -n "$review_requested" ]] || review_requested=null
  else
    gh_note="gh unavailable or not authenticated"
  fi
  jq -n --argjson s "$src" --arg def "$def" --argjson fetch_ok "$fetch_ok" --argjson commits "$commits" \
        --argjson branches "$branches" --argjson prs "$prs" --argjson rr "$review_requested" --arg gh_note "${gh_note:-}" \
        --argjson wt "$(git_worktrees_json "$repo")" \
    '$s + {default_branch: $def, fetch_ok: $fetch_ok, commits_since: $commits, branches: $branches,
           open_prs: $prs, review_requested_prs: $rr, gh_note: (if $gh_note == "" then null else $gh_note end),
           worktrees: $wt}'
}

pull_worktrees() {
  local src="$1" repo herdr_wt=null
  repo="$(jq -r .path <<<"$src")"
  if in_herdr; then
    herdr_wt="$(herdr worktree list --cwd "$repo" 2>/dev/null | jq '.result.worktrees // [] | map({path, branch, label, workspace: .open_workspace_id, linked: .is_linked_worktree})' || echo null)"
    [[ -n "$herdr_wt" ]] || herdr_wt=null
  fi
  jq -n --argjson s "$src" --argjson wt "$(git_worktrees_json "$repo")" --argjson hw "$herdr_wt" \
    '$s + {git_worktrees: $wt, herdr_worktrees: $hw}'
}

pull_roadmap() {
  local src="$1" f dir inprog="" ledger=""
  f="$(jq -r .path <<<"$src")"
  [[ -f "$f" ]] || { jq -n --argjson s "$src" '$s + {error: "roadmap file missing"}'; return; }
  dir="$(dirname "$f")"
  [[ -f "$dir/in-progress.md" ]] && inprog="$dir/in-progress.md"
  [[ -f "$dir/completed-prds.md" ]] && ledger="$dir/completed-prds.md"
  section_slugs() { awk -v h="## $1" '$0==h{f=1;next} /^## /{f=0} f' "$f" | grep -o '`[^`]*`' | tr -d '`' | jq -R . | jq -s .; }
  jq -n --argjson s "$src" \
    --argjson now "$(section_slugs Now)" --argjson next "$(section_slugs Next)" --argjson later "$(section_slugs Later)" \
    --arg mtime "$(date -u -r "$f" +%Y-%m-%dT%H:%M:%SZ)" \
    --arg inprog "$inprog" --arg inprog_harvested "$([[ -n "$inprog" ]] && grep -m1 '^Harvested:' "$inprog" | sed 's/^Harvested: *//' || true)" \
    --arg ledger "$ledger" --argjson ledger_rows "$([[ -n "$ledger" ]] && grep -c '^| [0-9]' "$ledger" || echo 0)" \
    --argjson paf "$(jq '.tools.pallas_agent_flow.available // false' "$TOOLS" 2>/dev/null || echo false)" \
    '$s + {now: $now, next: $next, later: $later, roadmap_mtime: $mtime,
           in_progress: (if $inprog == "" then null else {path: $inprog, harvested: $inprog_harvested} end),
           completed_prds: (if $ledger == "" then null else {path: $ledger, rows: $ledger_rows} end),
           delegate: (if $paf then "pallas-agent-flow:project-manager" else null end)}'
}

pull_linear() {
  jq -n --argjson s "$1" '$s + {pulled_by: "session", note: "Pull in-session with Linear MCP tools or the linear-api skill; the script cannot."}'
}

herdr_agents_json() {
  in_herdr || { echo null; return; }
  local out
  out="$(herdr agent list 2>/dev/null |
    jq '.result.agents // [] | map({agent, status: .agent_status, cwd, pane_id, workspace_id, title: .terminal_title_stripped})' || true)"
  printf '%s' "${out:-null}"
}

cmd_pull() {
  ensure_registry
  local since="" only="" quiet=false
  while (($#)); do
    case "$1" in
      --since) since="${2:?}"; shift 2 ;;
      --source) only="${2:?}"; shift 2 ;;
      --quiet) quiet=true; shift ;;
      *) usage ;;
    esac
  done
  [[ -n "$since" ]] || since="$(jq -r '.cursor.last_brief_at // empty' "$REGISTRY")"
  [[ -n "$since" ]] || since="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)"
  [[ -f "$TOOLS" ]] || cmd_detect >/dev/null

  local results=()
  while IFS= read -r src; do
    [[ -n "$src" ]] || continue
    local id kind
    id="$(jq -r .id <<<"$src")"; kind="$(jq -r .kind <<<"$src")"
    [[ -z "$only" || "$only" == "$id" ]] || continue
    case "$kind" in
      git) results+=("$(pull_git "$src" "$since")") ;;
      worktrees) results+=("$(pull_worktrees "$src")") ;;
      roadmap) results+=("$(pull_roadmap "$src")") ;;
      linear) results+=("$(pull_linear "$src")") ;;
    esac
  done < <(jq -c '.sources[]' "$REGISTRY")

  local out="$HOME_DIR/snapshots/$(date -u +%Y%m%dT%H%M%SZ).json"
  printf '%s\n' "${results[@]:-}" | jq -s --arg at "$(now_iso)" --arg since "$since" --argjson agents "$(herdr_agents_json)" \
    '{pulled_at: $at, since: $since, herdr_agents: $agents, sources: map(select(. != null and . != ""))}' >"$out"
  if $quiet; then
    jq -c --arg path "$out" '{snapshot: $path, pulled_at, since,
      sources: (.sources | map({id, kind, error,
        commits: (.commits_since // [] | length), open_prs: (.open_prs // [] | length),
        branches: (.branches // [] | length), worktrees: ((.worktrees // .git_worktrees // []) | length)})),
      herdr_agents: ((.herdr_agents // []) | group_by(.status) | map({(.[0].status): length}) | add // {})}' "$out"
  else
    cat "$out"
  fi
}

cmd_snapshot() {
  ensure_registry
  case "${1:-}" in
    latest) ls -1 "$HOME_DIR/snapshots"/*.json 2>/dev/null | tail -1 ;;
    since)
      local iso="${2:?ISO timestamp}" key
      key="$(tr -d ':-' <<<"$iso" | cut -c1-15)Z"
      for f in "$HOME_DIR/snapshots"/*.json; do
        [[ -e "$f" ]] || break
        [[ "$(basename "$f" .json)" > "$key" ]] && echo "$f"
      done
      ;;
    *) usage ;;
  esac
}

cmd_cursor() {
  ensure_registry
  [[ "${1:-}" == set ]] || usage
  jq --arg at "${2:-$(now_iso)}" '.cursor.last_brief_at = $at' "$REGISTRY" | write_registry
  jq '.cursor' "$REGISTRY"
}

# ---------------------------------------------------------------- reports

cmd_report() {
  ensure_registry
  case "${1:-}" in
    new)
      mkdir -p "$HOME_DIR/reports"
      printf '%s/reports/%s.md\n' "$HOME_DIR" "$(stamp)"
      ;;
    open)
      local file="${2:?report path}"
      [[ -f "$file" ]] || { printf 'No report at %s\n' "$file" >&2; exit 1; }
      if in_herdr && command -v glow >/dev/null; then
        local created pane tab
        created="$(herdr tab create --cwd "$(dirname "$file")" --label "brief $(basename "$file" .md)" --no-focus)"
        pane="$(jq -r '.result.root_pane.pane_id // .result.pane.pane_id // empty' <<<"$created")"
        tab="$(jq -r '.result.root_pane.tab_id // .result.tab.tab_id // .result.tab.id // empty' <<<"$created")"
        if [[ -z "$pane" && -n "$tab" ]]; then
          pane="$(herdr pane list | jq -r --arg t "$tab" '.result.panes[] | select(.tab_id == $t) | .pane_id' | head -1)"
        fi
        [[ -n "$pane" ]] || { printf 'Could not resolve the new tab pane: %s\n' "$created" >&2; exit 1; }
        herdr pane run "$pane" "glow -p '$file'" >/dev/null
        herdr notification show "Brief ready" --body "$(basename "$file")" --sound done >/dev/null 2>&1 || true
        jq -n --arg file "$file" --arg pane "$pane" --arg tab "$tab" '{opened: "herdr", file: $file, pane_id: $pane, tab_id: $tab}'
      elif command -v glow >/dev/null; then
        jq -n --arg file "$file" '{opened: "none", file: $file, hint: ("glow -p " + $file)}'
      else
        jq -n --arg file "$file" '{opened: "none", file: $file, hint: "install glow or read the file directly"}'
      fi
      ;;
    *) usage ;;
  esac
}

# ---------------------------------------------------------------- watch

epoch_for_hhmm() {
  # $1 HH:MM local. Next occurrence, as epoch seconds (today if still ahead, else tomorrow).
  local today t now
  today="$(date +%Y-%m-%d)"
  now="$(date +%s)"
  t="$(date -j -f '%Y-%m-%d %H:%M' "$today $1" +%s 2>/dev/null || date -d "$today $1" +%s)"
  (( t > now )) || t=$((t + 86400))
  printf '%s' "$t"
}

cmd_fire_brief() {
  # Ask a Claude agent in Herdr to write the brief. Starts one when none is alive.
  ensure_registry
  local agent=chief prompt="/pallas-chief-of-staff:chief-of-staff brief" plugin_dir
  plugin_dir="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
  while (($#)); do
    case "$1" in
      --agent) agent="${2:?}"; shift 2 ;;
      --prompt) prompt="${2:?}"; shift 2 ;;
      --plugin-dir) plugin_dir="${2:?}"; shift 2 ;;
      *) usage ;;
    esac
  done
  in_herdr || { printf 'fire-brief needs a Herdr session (HERDR_ENV=1).\n' >&2; exit 1; }

  local status="" pane="" started=false
  if herdr agent get "$agent" >/dev/null 2>&1; then
    status="$(herdr agent get "$agent" | jq -r '.result.agent.agent_status // "unknown"')"
    if [[ "$status" == working ]]; then
      herdr agent wait "$agent" --timeout 600000 >/dev/null 2>&1 || true
      status="$(herdr agent get "$agent" | jq -r '.result.agent.agent_status // "unknown"')"
    fi
    if [[ "$status" == blocked ]]; then
      herdr notification show "Brief not sent" --body "$agent is waiting on an approval" --sound request >/dev/null 2>&1 || true
      jq -n --arg agent "$agent" --arg status "$status" '{fired: false, agent: $agent, status: $status, reason: "agent blocked"}'
      return 1
    fi
  else
    local cwd created
    cwd="$(jq -r '[.sources[] | select(.kind == "git") | .path][0] // empty' "$REGISTRY")"
    [[ -n "$cwd" && -d "$cwd" ]] || cwd="$HOME_DIR"
    created="$(herdr tab create --cwd "$cwd" --label "$agent" --no-focus)"
    pane="$(jq -r '.result.root_pane.pane_id // .result.pane.pane_id // empty' <<<"$created")"
    [[ -n "$pane" ]] || { printf 'Could not create a pane for %s: %s\n' "$agent" "$created" >&2; exit 1; }
    herdr agent start "$agent" --kind claude --pane "$pane" --timeout 90000 -- --plugin-dir "$plugin_dir" >/dev/null
    started=true
  fi
  herdr agent prompt "$agent" "$prompt" >/dev/null
  herdr notification show "Brief requested" --body "$agent is writing the brief" --sound done >/dev/null 2>&1 || true
  jq --arg at "$(now_iso)" '.watch.last_fired_at = $at' "$REGISTRY" | write_registry 2>/dev/null || true
  jq -n --arg agent "$agent" --argjson started "$started" --arg pane "$pane" \
    '{fired: true, agent: $agent, started_new_agent: $started, pane_id: (if $pane == "" then null else $pane end)}'
}

cmd_collect() {
  # The loop that runs inside the watch pane. Pulls every interval; fires the brief at --brief-at.
  ensure_registry
  local interval=900 brief_at="" agent=chief plugin_dir=""
  while (($#)); do
    case "$1" in
      --interval) interval="${2:?}"; shift 2 ;;
      --brief-at) brief_at="${2:?}"; shift 2 ;;
      --agent) agent="${2:?}"; shift 2 ;;
      --plugin-dir) plugin_dir="${2:?}"; shift 2 ;;
      *) usage ;;
    esac
  done
  local next_fire=0
  [[ -z "$brief_at" ]] || next_fire="$(epoch_for_hhmm "$brief_at")"
  while :; do
    cmd_pull --quiet || printf '%s pull failed\n' "$(now_iso)" >&2
    if (( next_fire > 0 )) && (( $(date +%s) >= next_fire )); then
      # Late after a sleep is still fired, once; the next target is the following day.
      cmd_fire_brief --agent "$agent" ${plugin_dir:+--plugin-dir "$plugin_dir"} || true
      next_fire=$((next_fire + 86400))
      while (( next_fire <= $(date +%s) )); do next_fire=$((next_fire + 86400)); done
    fi
    local wait="$interval"
    if (( next_fire > 0 )); then
      local until=$((next_fire - $(date +%s)))
      (( until < wait )) && wait="$until"
    fi
    (( wait >= 1 )) || wait=1
    sleep "$wait"
  done
}

cmd_watch() {
  ensure_registry
  case "${1:-}" in
    start)
      shift
      local interval=900 brief_at="" agent=chief plugin_dir=""
      while (($#)); do
        case "$1" in
          --interval) interval="${2:?}"; shift 2 ;;
          --brief-at) brief_at="${2:?}"; shift 2 ;;
          --agent) agent="${2:?}"; shift 2 ;;
          --plugin-dir) plugin_dir="${2:?}"; shift 2 ;;
          *) usage ;;
        esac
      done
      [[ -z "$brief_at" || "$brief_at" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]] || { printf -- '--brief-at wants HH:MM, got %s\n' "$brief_at" >&2; exit 2; }
      in_herdr || { printf 'watch start needs a Herdr session (HERDR_ENV=1).\n' >&2; exit 1; }
      # Name the calling agent so the collector knows who to prompt in the morning.
      local caller
      caller="$(herdr pane current 2>/dev/null | jq -r '.result.pane.pane_id // .result.pane_id // empty' || true)"
      [[ -z "$caller" ]] || herdr agent rename "$caller" "$agent" >/dev/null 2>&1 || true
      local existing
      existing="$(jq -r '.watch.pane_id // empty' "$REGISTRY")"
      if [[ -n "$existing" ]] && herdr pane get "$existing" >/dev/null 2>&1; then
        herdr pane close "$existing" >/dev/null 2>&1 || true
      fi
      local created pane cmd
      created="$(herdr tab create --cwd "$HOME_DIR" --label "chief watch" --no-focus)"
      pane="$(jq -r '.result.root_pane.pane_id // .result.pane.pane_id // empty' <<<"$created")"
      [[ -n "$pane" ]] || { printf 'Could not create the watch pane: %s\n' "$created" >&2; exit 1; }
      cmd="'$SCRIPT_PATH' collect --interval $interval --agent $agent"
      [[ -z "$brief_at" ]] || cmd="$cmd --brief-at $brief_at"
      [[ -z "$plugin_dir" ]] || cmd="$cmd --plugin-dir '$plugin_dir'"
      herdr pane run "$pane" "$cmd" >/dev/null
      jq --arg pane "$pane" --argjson i "$interval" --arg at "$(now_iso)" --arg brief_at "$brief_at" --arg agent "$agent" \
        '.watch = {pane_id: $pane, interval_seconds: $i, started_at: $at, agent: $agent,
                   brief_at: (if $brief_at == "" then null else $brief_at end), last_fired_at: null}' "$REGISTRY" | write_registry
      jq '.watch' "$REGISTRY"
      ;;
    stop)
      local pane
      pane="$(jq -r '.watch.pane_id // empty' "$REGISTRY")"
      if [[ -n "$pane" ]] && in_herdr; then herdr pane close "$pane" >/dev/null 2>&1 || true; fi
      jq '.watch = null' "$REGISTRY" | write_registry
      echo '{"watch": null}'
      ;;
    *) usage ;;
  esac
}

# ---------------------------------------------------------------- dispatch

cmd="${1:-}"; shift || true
case "$cmd" in
  home) printf '%s\n' "$HOME_DIR" ;;
  init) cmd_init ;;
  detect) cmd_detect ;;
  source) cmd_source "$@" ;;
  pull) cmd_pull "$@" ;;
  snapshot) cmd_snapshot "$@" ;;
  cursor) cmd_cursor "$@" ;;
  report) cmd_report "$@" ;;
  watch) cmd_watch "$@" ;;
  collect) cmd_collect "$@" ;;
  fire-brief) cmd_fire_brief "$@" ;;
  *) usage ;;
esac
