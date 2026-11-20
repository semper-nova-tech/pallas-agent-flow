#!/usr/bin/env bash
# Runs chief.sh against a fake herdr and gh in a scratch home, and asserts what it does.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat >"$tmp/bin-herdr" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$FAKE_LOG"
case "$1 ${2:-}" in
  "--version ") echo "herdr 9.9.9" ;;
  "agent list") echo '{"result":{"agents":[
    {"agent":"claude","agent_status":"blocked","cwd":"/r","pane_id":"w1:p2","workspace_id":"w1","terminal_title_stripped":"Fix thing"},
    {"agent":"codex","agent_status":"idle","cwd":"/r2","pane_id":"w2:p1","workspace_id":"w2","terminal_title_stripped":"Idle"}]}}' ;;
  "worktree list") echo '{"result":{"worktrees":[{"path":"/r","branch":"main","label":"r","open_workspace_id":"w1","is_linked_worktree":false}]}}' ;;
  "tab create") echo '{"result":{"root_pane":{"workspace_id":"w1","tab_id":"w1:t9","pane_id":"w1:p9"}}}' ;;
  "pane get") echo '{"result":{"pane":{"pane_id":"w1:p9"}}}' ;;
  "pane current") echo '{"result":{"pane":{"pane_id":"w1:p1"}}}' ;;
  "agent get") [[ -n "${FAKE_AGENT_STATUS:-}" ]] || exit 1
               echo "{\"result\":{\"agent\":{\"agent\":\"${FAKE_AGENT_KIND:-claude}\",\"agent_status\":\"$FAKE_AGENT_STATUS\",\"pane_id\":\"w1:p1\"}}}" ;;
  *) echo '{"result":{"type":"ok"}}' ;;
esac
EOF
cat >"$tmp/bin-gh" <<'EOF'
#!/usr/bin/env bash
printf 'gh %s\n' "$*" >>"$FAKE_LOG"
case "$1 ${2:-}" in
  "auth status") exit 0 ;;
  "pr list") echo '[]' ;;
esac
EOF
mkdir -p "$tmp/bin" && mv "$tmp/bin-herdr" "$tmp/bin/herdr" && mv "$tmp/bin-gh" "$tmp/bin/gh" && chmod +x "$tmp/bin/"*
export PATH="$tmp/bin:$PATH" FAKE_LOG="$tmp/log" HERDR_ENV=1 HOME="$tmp/home" PALLAS_CHIEF_HOME="$tmp/chief"
mkdir -p "$HOME"
: >"$FAKE_LOG"

# A repository with one commit and a roadmap.
repo="$tmp/repo"
git init -q -b main "$repo"
mkdir -p "$repo/product"
printf '# Roadmap\n\n## Now\n\n- `alpha-thing`\n- `beta-thing`\n\n## Next\n\n- `gamma`\n\n## Later\n' >"$repo/product/roadmap.md"
git -C "$repo" -c user.name=t -c user.email=t@t add -A
git -C "$repo" -c user.name=t -c user.email=t@t commit -q -m init

chief="$here/chief.sh"

out="$(bash "$chief" init)"
[[ "$(jq -r '.sources | length' <<<"$out")" == 0 ]]
[[ "$(jq -r .script_path <<<"$out")" == "$chief" ]]

out="$(bash "$chief" detect)"
[[ "$(jq -r .tools.herdr.available <<<"$out")" == true ]]
[[ "$(jq -r .tools.herdr.inside_session <<<"$out")" == true ]]
[[ "$(jq -r .tools.gh.authenticated <<<"$out")" == true ]]
[[ "$(jq -r .tools.pallas_agent_flow.available <<<"$out")" == false ]]

[[ "$(bash "$chief" source add --kind git --path "$repo" | jq -r .id)" == git-repo ]]
[[ "$(bash "$chief" source add --kind worktrees --path "$repo" | jq -r .id)" == worktrees-repo ]]
[[ "$(bash "$chief" source add --kind roadmap --path "$repo/product/roadmap.md" | jq -r .kind)" == roadmap ]]
[[ "$(bash "$chief" source add --kind linear --spec me | jq -r .spec)" == me ]]
[[ "$(bash "$chief" source list | jq 'length')" == 4 ]]

out="$(bash "$chief" pull --quiet)"
snap="$(jq -r .snapshot <<<"$out")"
[[ -f "$snap" ]]
[[ "$(jq -r .herdr_agents.blocked <<<"$out")" == 1 ]]
[[ "$(jq -r '.sources[] | select(.kind=="git") | .default_branch' "$snap")" == main ]]
[[ "$(jq -r '.sources[] | select(.kind=="git") | .fetch_ok' "$snap")" == false ]]
[[ "$(jq -r '.sources[] | select(.kind=="git") | .open_prs | length' "$snap")" == 0 ]]
[[ "$(jq -r '.sources[] | select(.kind=="git") | .worktrees[0].branch' "$snap")" == main ]]
[[ "$(jq -r '.sources[] | select(.kind=="worktrees") | .herdr_worktrees[0].path' "$snap")" == /r ]]
[[ "$(jq -c '.sources[] | select(.kind=="roadmap") | .now' "$snap")" == '["alpha-thing","beta-thing"]' ]]
[[ "$(jq -r '.sources[] | select(.kind=="roadmap") | .delegate' "$snap")" == null ]]
[[ "$(jq -r '.sources[] | select(.kind=="linear") | .pulled_by' "$snap")" == session ]]
[[ "$(bash "$chief" snapshot latest)" == "$snap" ]]
[[ "$(bash "$chief" snapshot since 2000-01-01T00:00:00Z | wc -l | tr -d ' ')" == 1 ]]

report="$(bash "$chief" report new)"
printf '# Brief\n' >"$report"
: >"$FAKE_LOG"
out="$(bash "$chief" report open "$report")"
[[ "$(jq -r .pane_id <<<"$out")" == w1:p9 ]]
grep -q -- "tab create --cwd $(dirname "$report") --label brief" "$FAKE_LOG"
grep -q -- "pane run w1:p9 glow -p '$report'" "$FAKE_LOG"
grep -q -- "notification show Brief ready" "$FAKE_LOG"

: >"$FAKE_LOG"
out="$(bash "$chief" watch start --interval 60)"
[[ "$(jq -r .pane_id <<<"$out")" == w1:p9 ]]
[[ "$(jq -r .brief_at <<<"$out")" == null ]]
grep -q -- "agent rename w1:p1 chief" "$FAKE_LOG"
# No agent in the calling pane: the kind defaults to claude.
[[ "$(jq -r .kind <<<"$out")" == claude ]]
grep -q -- "pane run w1:p9 '$chief' collect --interval 60 --agent chief --kind claude$" "$FAKE_LOG"
# A second start replaces the live pane, carries the brief time, and takes the caller's kind.
: >"$FAKE_LOG"
out="$(FAKE_AGENT_STATUS=idle FAKE_AGENT_KIND=cursor bash "$chief" watch start --brief-at 06:45 --agent morning)"
[[ "$(jq -r .brief_at <<<"$out")" == 06:45 ]]
[[ "$(jq -r .kind <<<"$out")" == cursor ]]
grep -q -- "pane close w1:p9" "$FAKE_LOG"
grep -q -- "collect --interval 900 --agent morning --kind cursor --brief-at 06:45$" "$FAKE_LOG"
# An explicit --kind wins.
[[ "$(FAKE_AGENT_STATUS=idle FAKE_AGENT_KIND=cursor bash "$chief" watch start --kind codex | jq -r .kind)" == codex ]]
! bash "$chief" watch start --brief-at 6:45 >/dev/null 2>&1

# fire-brief: idle agent gets the prompt.
: >"$FAKE_LOG"
out="$(FAKE_AGENT_STATUS=idle bash "$chief" fire-brief --agent chief)"
[[ "$(jq -r .fired <<<"$out")" == true ]]
[[ "$(jq -r .started_new_agent <<<"$out")" == false ]]
grep -q -- "agent prompt chief /pallas-chief-of-staff:chief-of-staff brief" "$FAKE_LOG"
! grep -q -- "agent start" "$FAKE_LOG"
# fire-brief: a working agent is waited for first.
: >"$FAKE_LOG"
FAKE_AGENT_STATUS=working bash "$chief" fire-brief >/dev/null
grep -q -- "agent wait chief --timeout 600000" "$FAKE_LOG"
grep -q -- "agent prompt chief" "$FAKE_LOG"
# fire-brief: a blocked agent is left alone.
: >"$FAKE_LOG"
! FAKE_AGENT_STATUS=blocked bash "$chief" fire-brief >/dev/null
! grep -q -- "agent prompt" "$FAKE_LOG"
grep -q -- "notification show Brief not sent" "$FAKE_LOG"
# fire-brief: no agent alive starts one in a new tab with the plugin dir, on the watch's harness.
: >"$FAKE_LOG"
out="$(bash "$chief" fire-brief --plugin-dir /plug)"
[[ "$(jq -r .started_new_agent <<<"$out")" == true ]]
[[ "$(jq -r .kind <<<"$out")" == codex ]]
grep -q -- "tab create --cwd $repo --label chief --no-focus" "$FAKE_LOG"
grep -q -- "agent start chief --kind codex --pane w1:p9 --timeout 90000 -- --plugin-dir /plug" "$FAKE_LOG"
grep -q -- "agent prompt chief /pallas-chief-of-staff:chief-of-staff brief" "$FAKE_LOG"
# --kind on fire-brief overrides the watch, and --prompt replaces the slash command.
: >"$FAKE_LOG"
bash "$chief" fire-brief --kind cursor --prompt "/chief-of-staff brief" >/dev/null
grep -q -- "agent start chief --kind cursor --pane w1:p9" "$FAKE_LOG"
grep -q -- "agent prompt chief /chief-of-staff brief" "$FAKE_LOG"
: >"$FAKE_LOG"
bash "$chief" watch stop >/dev/null
grep -q -- "pane close w1:p9" "$FAKE_LOG"
[[ "$(jq -r .watch "$PALLAS_CHIEF_HOME/registry.json")" == null ]]

[[ "$(bash "$chief" cursor set 2026-01-02T03:04:05Z | jq -r .last_brief_at)" == 2026-01-02T03:04:05Z ]]
[[ "$(bash "$chief" pull --quiet | jq -r .since)" == 2026-01-02T03:04:05Z ]]

# Outside Herdr: open falls back, watch refuses.
: >"$FAKE_LOG"
out="$(HERDR_ENV= bash "$chief" report open "$report")"
[[ "$(jq -r .opened <<<"$out")" == none ]]
! grep -q -- "tab create" "$FAKE_LOG"
! HERDR_ENV= bash "$chief" watch start >/dev/null 2>&1

echo ok
