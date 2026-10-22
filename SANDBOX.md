# SANDBOX.md — the 1.9 GB doctrine

## The number

Each sandbox has ~1.9 GB RAM. The OS + a lightweight desktop (LXQt/Openbox)
take ~300–500 MB idle. That leaves roughly 1.2–1.4 GB for all agent processes
combined.

## Hard cap per process (cgroups v2)

Every agent process is launched under a cgroup with `memory.max = 1200M`
(~1.2 GB). Hit the cap → cgroup-scoped OOM kills only that process, not the box.

```bash
# one-time setup (needs root/sudo on the sandbox)
sudo mkdir -p /sys/fs/cgroup/crew
echo +memory | sudo tee /sys/fs/cgroup/cgroup.subtree_control
echo 1200M | sudo tee /sys/fs/cgroup/crew/memory.max

# run a command inside the cap
echo $$ | sudo tee /sys/fs/cgroup/crew/cgroup.procs
blender --background --python render.py
```

`tools/blender-lowmem.sh` wraps Blender in this cap automatically.

## Blender on low RAM (your current work)

- **Headless:** `blender --background --python script.py --render-output …`
  (never launch the GUI in the sandbox)
- **Cycles "Lower Memory" preset**; tile size 512–1024; **disable Persistent
  Data** (it holds peak memory between frames and is a leak source)
- Memory Cache Limit ≈ 70–80% of the cap (~900 MB)
- Downscale non-hero textures to 1K/512 (halving resolution quarters memory);
  decimate geometry; use the Simplify panel
- `bpy` leaks RAM since 4.0 → **restart Blender per render job** (chunk work)
- Render layers separately, composite afterward
- `CYCLES_CONCURRENT_STATES_FACTOR=0.6` reduces concurrent-state memory

## Chunk everything

- ≤1.2 GB per process
- `/tmp` is scratch (vanishes on reboot) — never the only copy of anything
- Only `git push` survives
- Long renders → one frame/job per agent session, then push and exit

## Never

- Don't run GNOME/KDE/Electron browsers in the sandbox (500 MB–1 GB idle)
- Don't let Blender grow past the cap without chunking
- Don't store the only copy of anything in `/tmp`
