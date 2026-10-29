# Detailed mesh models

Items and shop/town props have a detailed mesh version made in Blender with code.
The game uses the mesh when it's uploaded, and falls back to the part-built model otherwise.

## How it works
1. `tools/meshes/models/<Id>.py` builds the model with helpers from `tools/meshes/lib.py`.
2. `tools/meshes/build.py <Id>` exports `assets/meshes/<Id>.fbx` + `<Id>.json` (size, colors per part)
   and renders `docs/previews/meshes/<Id>.png`.
3. `tools/meshes/upload.py <Id>` uploads the FBX to Roblox as a Model asset (Open Cloud),
   saves the asset ID in `assets/meshes/uploaded.json`, and regenerates `src/server/MeshCatalog.luau`.
4. In game, `src/server/MeshLoader.luau` loads each asset with `InsertService:LoadAsset`,
   recolors parts by name, stands it upright, scales it to the size in the catalog, and
   `ItemModels.Build` uses it instead of the part model.

## Props
Prop models are named `Prop<Name>.py` (e.g. `PropStreetLamp.py`) and set `KEEP_ORIGIN = True`.
Their (0, 0, 0) point is where they attach: the bottom of a lamp pole, the back of a wall clock,
the hook of the chandelier. `build.py` saves it as `Origin`, and the game places the prop by that point.
- Keep props centered left/right (X), and the front facing -Y like items.
- A part with the look name `Accent` is painted in each shop's own color (the cash register).
- A part with the look name `Glow` gets a light when the prop asks for one (lamps, lanterns, chandelier).
- `src/server/Props.luau` places a prop; `ShopBuilder` and `TownBuilder` fall back to parts if it isn't uploaded.
- Big pieces (shop building, interior, counter, cases, shelves, plaza, arch) cover the plain parts, which
  `Props.Hide` makes invisible but keeps solid, so walking, item spots and text signs work the same.
  These models are written with `lib.R` / `lib.rbox` in the same Roblox coordinates as the Luau code.
- Repeating pieces (road, sidewalk, hedge) are 8 studs long and lined up with `Props.Row`.

## Orientation
`build.py` saves where each part sits (`Centers`). Roblox can import a model lying down or turned
around, so `MeshLoader` tries each way and keeps the one where the parts are where they should be.

## Setup in a cloud session
```
python3 -m venv /tmp/bvenv && /tmp/bvenv/bin/pip install bpy==5.2.3
/tmp/bvenv/bin/python tools/meshes/build.py AcousticGuitar GoldTrophy RoyalCrown
python3 tools/meshes/upload.py AcousticGuitar GoldTrophy RoyalCrown
# or everything at once:
/tmp/bvenv/bin/python tools/meshes/build.py --all
python3 tools/meshes/upload.py --all
```
Uploading needs these environment variables (set in the cloud environment settings, never in code or chat):
- `ROBLOX_API_KEY` – Open Cloud API key with **Assets API: Read + Write**, accepted IP `0.0.0.0/0`
- `ROBLOX_USER_ID` – the Roblox user ID that owns the game

## Status
- [x] Samples built: AcousticGuitar, GoldTrophy, RoyalCrown (previews in `docs/previews/meshes/`)
- [x] Samples uploaded (asset IDs in `assets/meshes/uploaded.json`)
- [x] Samples checked in Studio (right way up, facing forward, right colors)
- [x] Remaining 19 items built and uploaded
- [x] Props built and uploaded: cash register, service bell, safe, chandelier, retro TV, wall clock,
      door lanterns, pawn balls sign, potted plant, potted bush, street lamp, bench, fountain, tree
- [x] Shop building, interior, counter, display cases, wall shelves, road, sidewalks, hedges,
      plaza floor and arch built and uploaded
- [ ] Everything checked in Studio
