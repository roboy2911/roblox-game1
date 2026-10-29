"""Builds item models: exports an FBX + look data, and renders a preview.

Usage (from the repo root, with Blender's Python module installed):
    python tools/meshes/build.py AcousticGuitar GoldTrophy ...
    python tools/meshes/build.py --all
    add --no-render to skip the preview, or --info-only to only rewrite the .json files
Outputs:
    assets/meshes/<Id>.fbx        model file to upload to Roblox
    assets/meshes/<Id>.json       colors/materials per part, size
    docs/previews/meshes/<Id>.png preview picture
"""

import importlib.util
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)

import lib  # noqa: E402

OUT = os.path.join(ROOT, "assets", "meshes")
PREVIEWS = os.path.join(ROOT, "docs", "previews", "meshes")


def build(model_id, render=True, export=True):
    spec = importlib.util.spec_from_file_location(model_id, os.path.join(HERE, "models", model_id + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    lib.reset()
    module.build(lib)
    looks = lib.merge_by_look()
    lo, hi = lib.bounds()
    tris = lib.triangle_counts()

    os.makedirs(OUT, exist_ok=True)
    os.makedirs(PREVIEWS, exist_ok=True)
    if export:
        lib.export_fbx(os.path.join(OUT, model_id + ".fbx"))
    size = hi - lo
    info = {
        "Id": model_id,
        # Roblox axes: X, Y (up), Z
        "Size": [round(size.x, 3), round(size.z, 3), round(size.y, 3)],
        "Parts": {name: look.to_dict() for name, look in looks.items()},
        "Triangles": tris,
    }
    # Blender -> Roblox axes. A model's front is -Y in Blender and -Z in Roblox, so Roblox X is
    # Blender -X (a turn, not a mirror): Roblox (X, Y, Z) = Blender (-x, z, y).
    def to_roblox(v):
        return [-v.x, v.z, v.y]

    center = (lo + hi) / 2
    longest = max(size.x, size.y, size.z)
    # Where each part sits inside the model (relative to the center, divided by the longest side).
    # The game uses this to turn the imported model the right way round.
    info["Centers"] = {}
    for name, (plo, phi) in lib.part_bounds().items():
        info["Centers"][name] = [round(c / longest, 4) for c in to_roblox((plo + phi) / 2 - center)]
    if getattr(module, "KEEP_ORIGIN", False):
        # Where the model's (0, 0, 0) sits, measured from the bottom-center of its bounding box,
        # in Roblox axes. The game uses it as the pivot, so a lamp is placed by the bottom of its
        # pole and a wall clock by its back.
        bottom_center = center.copy()
        bottom_center.z = lo.z
        info["Origin"] = [round(c, 3) + 0.0 for c in to_roblox(-bottom_center)]
    with open(os.path.join(OUT, model_id + ".json"), "w") as f:
        json.dump(info, f, indent=2)
    print(f"{model_id}: size {info['Size']}, triangles {sum(tris.values())} {tris}")
    for name, count in tris.items():
        if count > 20000:
            print(f"  WARNING: {name} has {count} triangles (Roblox limit is 20,000 per part)")
    if render:
        lib.render_preview(os.path.join(PREVIEWS, model_id + ".png"))


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if "--all" in sys.argv:
        args = sorted(f[:-3] for f in os.listdir(os.path.join(HERE, "models")) if f.endswith(".py"))
    for model_id in args:
        info_only = "--info-only" in sys.argv  # just rewrite the .json (no FBX, no preview)
        build(model_id, render="--no-render" not in sys.argv and not info_only, export=not info_only)
