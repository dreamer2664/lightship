# PROTOCOL — lightship crew law

Short on purpose. Read once before your first message. If a manager hands you
anything longer than a stub, the extra text is a job brief, not law — this file
is law.

## The three surfaces

| Surface | Where | For |
| --- | --- | --- |
| **bus** | `bus/<channel>.jsonl` | talk: claim, blocked, done, one-line pointers |
| **board** | `board/tasks/<id>.json` | work: one card, exactly one owner |
| **roster** | `agents/<name>.json` | identity: who exists, what they do, last seen |

Everything else (findings, reasoning, diffs, checklists, history) goes in
`memory/`, the task file, or a PR body. The bus gets **one line + a path**.
Never paste a long report on the bus.

## The rules

R1 — **One owner per task.** Claim with `crew tasks-claim <id>` before you start.
R2 — **Announce before you build.** `crew say "starting t-…: I will X"` --type claim
R3 — **Bus is for talking, not filing.** Short messages only; evidence lives in files.
R4 — **Report deltas, not narration.** No "thinking…". Post when something changes.
R5 — **Hand off with evidence.** A task goes to review only with a PR/branch/SHA/diff.
R6 — **Review is a duty.** Review at least as much as you produce. Concrete verdict.
R7 — **Escalate, never stall.** Blocked? Post `blocked: <what>; need <who>` within one turn.
R8 — **Never edit another agent's artifacts.** Read everything; write only your own.
R9 — **Two writers, one file = conflict.** Coordinate before touching a shared file.
R10 — **Stay in your lane.** Don't change PROTOCOL.md or the data layout. Propose ideas on the bus.

## Task lifecycle

```
open → claimed → review → done
        └─ blocked → (unblocked) → review
        └─ dropped
```

## The wire (contact everyone)

The bus is for records. The **wire** is for humans. One command reaches everyone:

```bash
python3 bin/crew notify "lumen — pushed the facade render right now, starting the roof now."
python3 bin/crew say "status" --type status --ref <id> --wire   # bus + wire together
```

- **Notify the wire on exactly four events:** you pushed something meaningful,
  you are blocked, CI is red, you are handing off or going away.
- **Message style:** `name — what happened right now, what you are doing now.`
  One line. No markdown, no logs, no essays.
- **Never** dump stack traces or file listings on the wire. Link the bus instead.
- Backends: `ntfy` (set `NTFY_TOPIC`) or `telegram` (set `TELEGRAM_BOT_TOKEN` +
  `TELEGRAM_CHAT_ID`). CI posts green/red results automatically.

## Liveness (short sessions)

- Heartbeat every ~25 min (`tools/pulse.sh`). Any board write is also a heartbeat.
- 45 minutes of silence while holding work = presumed dead → leases swept, work re-listed.
- Age 0–6h: **ROOKIE** — ≤4 h jobs and reviews only. 6–48h: **FULL**. 48–60h: **AGING** → run `crew handoff <id>` to write `RELAY.md`.
- Nothing lives in your head. Everything lives in a push.

## Memory (1.9 GB boxes)

See `SANDBOX.md`. Every agent process runs under a cgroup cap. Blender renders
headless via `tools/blender-lowmem.sh`, ≤1.2 GB per process, chunked so a single
session never holds more than one render job.
