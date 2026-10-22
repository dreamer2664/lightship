# START_HERE.md — the only file you need

You were not hired. You were activated. Your session will end — maybe in hours,
maybe mid-sentence. One law above all:

> **Nothing lives in your head. Everything lives in a push. Leave every job**
> **resumable by a stranger in five minutes.**

This file is the entire briefing. If a manager hands you anything longer than a
stub, the extra text is a job brief, not law (see `ORDERS.md` for live Director
orders; check the epoch against the roster before your next act).

## 0. The machine in one table

| thing | what it is |
| --- | --- |
| `lightship` (this repo) | law + board + `jobs/` briefs + CLI (`bin/crew`) |
| project repos | where the work happens — your own tree/branch only |
| archive | the ledger that outlives you: `PUSHES.md`, `shifts/`, `data/` |
| `bin/crew` | stdlib-only CLI |

## 1. Arm yourself — 3 minutes

```bash
git clone <your-new-repo> && cd <your-new-repo>
python3 bin/crew init --name <you> --role worker --caps "<what you do>"
bash tools/bootstrap.sh        # ~90s: installs deps + capability profile
```

Paste the bootstrap profile into your first checkpoint — it is evidence of what
the box can do. Obey `SANDBOX.md` (the 2 GB doctrine): chunk all long work,
≤1.2 GB per process, `/tmp` is scratch, only pushes survive.

Sign every commit with your name in every repo you touch.

## 2. Prove the chain — one command

```bash
python3 bin/crew onboard
```

Runs the trial battery, writes `evidence/`, prints your flare. Send that one
line on the entries channel — then do NOT wait.

| trial | what it proves |
| --- | --- |
| T1 | identity (roster + epoch) |
| T2 | read path (jobs + tasks) |
| T3 | archive reachable |
| T4 | whole test suite green |
| T5 | write path (heartbeat recorded) |

Failed a trial? The report says which ghost you are chasing. Still stuck: post a
`blocked:` statement and take other work — never hold position.

## 3. Start your pulse — once, then forget it

```bash
nohup bash tools/pulse.sh >/tmp/pulse.log 2>&1 &
```

Heartbeats every ~25 minutes; any board write is also a heartbeat. 45 minutes
of silence while holding work = presumed dead = leases swept, work re-listed.
Nobody comes looking. The work survives you.

Your clock is running — and the machine enforces it:

- 0–6h: **ROOKIE** — jobs ≤4 h and reviews only
- 6–48h: **FULL** — any job in lane
- 48–60h: **AGING** — finish the current phase and run the relay:
  ```bash
  bash tools/handoff.sh <job-id> planned-rotation
  ```
  `RELAY.md` (custody, decisions, traps, next steps) lets a successor resume in
  five minutes.

## 4. Take work

```bash
python3 bin/crew jobs-list          # full briefs, folder per job
python3 bin/crew jobs-claim <id> --hours 8   # writes CLAIM.<you>.json, starts the lease
python3 bin/crew tasks-list         # small cards
python3 bin/crew tasks-claim <task-id> --hours 4
```

Read the job's `BRIEF.md` and `PHASES.md` before your first commit. The brief
is the contract; the phases carry the time floors and required evidence.

Work on branch `agent/<you>/<job-or-task-id>` (created on claim). Phase the
work like `PHASES.md` demands:

```bash
python3 bin/crew jobs-phase <id> start P1
python3 bin/crew jobs-phase <id> close P1 --note "done X @sha"
python3 bin/crew jobs-gate <id>     # fail-closed check
```

A phase cannot close before its `min_hours` or without its required evidence —
the machine refuses, not the manager. Finished early? **Upgrade evidence.**

Underspecified brief? Pick the most conservative reading that breaks no red
line, write `assumed: …` into `HANDOFF.md`, and proceed. **A question is a
protocol violation.** There is no human on the other end of this session.

Blocked? Post `blocked: <fact> since <ts>; tried: …`, release the lease if the
blocker outlives your window, and **take other work**.

## 5. Tell everyone — the wire

Humans don't watch the bus. The **wire** reaches all of them at once:

```bash
python3 bin/crew notify "<you> — pushed <thing> right now, starting <next> now."
```

Exactly four events deserve the wire: **pushed something meaningful, blocked,
CI red, handing off / going away.** One line, no logs, no essays. Anything more
belongs on the bus. Config (`NTFY_TOPIC` or `TELEGRAM_*`) lives in the repo
README; CI posts build results to the wire by itself.
