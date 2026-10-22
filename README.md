# lightship — lightweight agent crew for tiny sandboxes

A git-native, serverless, database-free multi-agent system built for
~2 GB RAM Debian sandboxes. **The repo IS the system.**

Designed to replace chatcode when it gets too heavy. Small, resumable,
crash-resistant. Built around the work you're actually doing now:
Blender scenes, 3D models, and renders.

## The machine (one table)

| thing | what it is |
| --- | --- |
| `lightship` (this repo) | law + board + job briefs + CLI (`bin/crew`) |
| project repos | where the work happens (blend files, code, models, renders) |
| `agents/<name>.json` | roster + liveness (one file per agent) |
| `board/tasks/<id>.json` | one card per task, exactly one owner |
| `board/heartbeats/<name>.jsonl` | append-only pulse per agent |
| `bin/crew` | stdlib-only Python CLI (no `pip install`) |
| `tools/` | pulse, handoff, blender-lowmem, bootstrap |
| `memory/` | findings, reasoning, diffs (never the bus) |
| `evidence/` | artifacts: renders, screenshots, PR links, SHAs |

## Core ideas

- **Nothing lives in your head. Everything lives in a push.** Leave every job
  resumable by a stranger in five minutes.
- **One owner per task.** Atomic claims via git — no race, no noise.
- **Short sessions, long memory.** Agents live 2–3 days. Heartbeats, handoffs
  and `RELAY.md` make death cheap; a successor picks up in five minutes.
- **Memory is a hard limit, not a suggestion.** cgroups cap every agent process
  so one lazy Blender render can't OOM the whole 1.9 GB box (see `SANDBOX.md`).
- **No server, no database.** `git push` is the only write path. Works offline.

## Quick start

```bash
git clone <your-new-repo> && cd <your-new-repo>
python3 bin/crew init --name <you> --role worker --caps "<what you actually do>"
bash tools/bootstrap.sh            # ~90s: deps + capability profile
python3 bin/crew jobs-list
python3 bin/crew tasks-list
nohup bash tools/pulse.sh >/tmp/pulse.log 2>&1 &   # heartbeat, then forget it
```

Then take work:

```bash
python3 bin/crew tasks-claim t-20261022-001 --hours 4
# ... work on branch agent/<you>/<id> ...
python3 bin/crew tasks-update t-20261022-001 --status review --note "render @sha abc123"
```

## Contact wire

One command reaches every human watching the crew:

```bash
python3 bin/crew notify "lumen — pushed the facade render right now, starting the roof now."
```

Two backends, pick one (or both):

| backend | config | how |
| --- | --- | --- |
| **ntfy** (default) | topic `lightship` (override: `NTFY_TOPIC=<topic>`) | subscribe at ntfy.sh/lightship or in the ntfy app |
| telegram | `export TELEGRAM_BOT_TOKEN=… TELEGRAM_CHAT_ID=…` | bot API |

CI also posts green/red build results to the wire automatically (set repo
secrets `NTFY_TOPIC` or `TELEGRAM_*`). Wire etiquette lives in `PROTOCOL.md`
§ The wire: one line, four events only.

See `PROTOCOL.md` (the law), `START_HERE.md` (3-minute briefing), and
`SANDBOX.md` (the 1.9 GB memory doctrine).
