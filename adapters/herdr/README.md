# Herdr adapter

This optional adapter runs Pallas Agent Flow Cursor workers in real Herdr panes.
Native Cursor delegation remains the default.

## Prerequisites

- `herdr`
- `jq`
- Cursor Agent CLI (`agent`)
- a running or startable Herdr session

## Adapter contract

1. Create one Herdr workspace per Pallas Agent Flow run and use its root pane.
2. Start one worker per packet. `worker` splits the largest pane in that tab, starts
   Cursor Agent CLI with the packet's working directory and model, submits the packet
   with `herdr agent prompt --wait`, and returns when the worker settles.
3. `worker` exits non-zero when the worker ends `blocked` or the wait fails. Treat that
   as a recovery event, never success.
4. Run independent workers concurrently with `&` and the shell's `wait`.
5. Close a worker's pane with `close` only after the orchestrator has accepted its
   output. Keep failed panes open during recovery.
6. Keep the Pallas Agent Flow run artifacts and Git worktree state as the source of truth.

```bash
adapters/herdr/pallas-agent-flow-herdr.sh workspace \
  --cwd /path/to/repo \
  --label pallas-agent-flow
# {"workspace_id": "...", "tab_id": "...", "pane_id": "..."}

adapters/herdr/pallas-agent-flow-herdr.sh worker \
  --pane ROOT_PANE_ID \
  --name build-api \
  --cwd /path/to/worktree \
  --model cursor-grok-4.6-high-fast \
  --prompt-file /path/to/build-packet.md \
  --run-id RUN_ID \
  --packet-id PACKET_ID \
  --timeout 900000 &
adapters/herdr/pallas-agent-flow-herdr.sh worker ... &
wait

adapters/herdr/pallas-agent-flow-herdr.sh close --name build-api
```

`wait --name NAME` re-checks a worker that already received its prompt. Do not use it
to detect completion of a prompt that was just sent; `worker` already waited.

Do not close failed panes or delete failed worktrees during recovery. Herdr is the
visibility and input layer; Pallas Agent Flow remains responsible for packets, reviews,
commits, and recovery decisions.

Run `adapters/herdr/check.sh` after changing the script. It uses a fake `herdr`.
