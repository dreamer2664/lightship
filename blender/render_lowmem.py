#!/usr/bin/env python3
"""render_lowmem.py — headless Blender render tuned for ~1.2 GB RAM.

Usage:
    blender --background --python blender/render_lowmem.py -- --scene scene.blend --out /tmp/out.png
"""
import bpy
import sys
import os
import argparse

# --- parse argv after "--" --------------------------------------------------
argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
ap = argparse.ArgumentParser()
ap.add_argument("--scene", default=None, help="path to a .blend to open (optional)")
ap.add_argument("--out", default="/tmp/render.png", help="render output path")
ap.add_argument("--resolution", type=int, default=1080, help="render resolution (px)")
ap.add_argument("--samples", type=int, default=64, help="Cycles samples")
ap.add_argument("--tile", type=int, default=512, help="Cycles tile size (px)")
args = ap.parse_args(argv)

if args.scene and os.path.exists(args.scene):
    bpy.ops.wm.open_mainfile(filepath=args.scene)

scene = bpy.context.scene

# --- low-memory render settings --------------------------------------------
scene.render.engine = "CYCLES"
scene.cycles.samples = args.samples
scene.cycles.use_adaptive_sampling = True
scene.cycles.adaptive_threshold = 0.01
scene.cycles.use_denoising = False          # denoise needs extra peak RAM
scene.render.resolution_x = args.resolution
scene.render.resolution_y = args.resolution
scene.render.resolution_percentage = 50     # preview-scale; bump for finals
scene.render.tile_x = args.tile
scene.render.tile_y = args.tile
scene.cycles.persistent_data = False        # CRITICAL: don't hold peak RAM between frames
scene.render.use_persistent_data = False

# memory cache limit (~900 MB of the 1.2 GB cap)
prefs = bpy.context.preferences
prefs.memory_cache_limit_in_mb = 900
prefs.undo_steps = 0                        # undo history eats RAM

# texture simplify for viewport/preview
scene.render.use_simplify = True
scene.simplify.render_texture_limit = 512
scene.simplify.render_max_subdivision = 1

scene.render.filepath = args.out
scene.render.image_settings.file_format = "PNG"

print(f"render_lowmem: rendering → {args.out} ({args.resolution}x{args.resolution}, {args.samples}samples, tile {args.tile})")
bpy.ops.render.render(write_still=True)
print("render_lowmem: done")
