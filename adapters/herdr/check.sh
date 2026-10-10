#!/usr/bin/env bash
# Runs lore-flow-herdr.sh against a fake herdr and asserts the calls it makes.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat >"$tmp/herdr" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$FAKE_LOG"
case "$1 $2" in
  "workspace create") echo '{"result":{"root_pane":{"workspace_id":"w1","tab_id":"w1:t1","pane_id":"w1:p1"}}}' ;;
  "pane layout") echo '{"result":{"layout":{"panes":[
    {"pane_id":"w1:p1","rect":{"width":40,"height":50}},
    {"pane_id":"w1:p2","rect":{"width":140,"height":50}}]}}}' ;;
  "pane split") echo '{"result":{"pane":{"pane_id":"w1:p3"}}}' ;;
  "agent prompt") echo "{\"result\":{\"agent\":{\"agent_status\":\"$FAKE_STATUS\"}}}" ;;
  "agent get") echo '{"result":{"agent":{"pane_id":"w1:p3"}}}' ;;
esac
EOF
chmod +x "$tmp/herdr"
export PATH="$tmp:$PATH" FAKE_LOG="$tmp/log"
echo 'do the thing' >"$tmp/packet.md"

worker() {
  : >"$FAKE_LOG"
  FAKE_STATUS="$1" bash "$here/lore-flow-herdr.sh" worker --pane w1:p1 --name w \
    --cwd /tmp --model m --prompt-file "$tmp/packet.md"
}

out="$(bash "$here/lore-flow-herdr.sh" workspace --cwd /tmp --label x)"
[[ "$(jq -r .pane_id <<<"$out")" == w1:p1 ]]

out="$(worker done)"
[[ "$(jq -r .pane_id <<<"$out")" == w1:p3 ]]
grep -q -- 'pane split --pane w1:p2 --direction right' "$FAKE_LOG"
grep -q -- 'agent prompt w do the thing --wait' "$FAKE_LOG"
! grep -q report-metadata "$FAKE_LOG"

! worker blocked >/dev/null

: >"$FAKE_LOG"
bash "$here/lore-flow-herdr.sh" close --name w
grep -q -- 'pane close w1:p3' "$FAKE_LOG"

echo ok
