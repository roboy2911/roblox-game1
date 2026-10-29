# Detailed mesh models

Items (and later shop props) can have a detailed mesh version made in Blender with code.
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

## Setup in a cloud session
```
python3 -m venv /tmp/bvenv && /tmp/bvenv/bin/pip install bpy==5.2.3
/tmp/bvenv/bin/python tools/meshes/build.py AcousticGuitar GoldTrophy RoyalCrown
python3 tools/meshes/upload.py AcousticGuitar GoldTrophy RoyalCrown
```
Uploading needs these environment variables (set in the cloud environment settings, never in code or chat):
- `ROBLOX_API_KEY` – Open Cloud API key with **Assets API: Read + Write**, accepted IP `0.0.0.0/0`
- `ROBLOX_USER_ID` – the Roblox user ID that owns the game

## Status
- [x] Samples built: AcousticGuitar, GoldTrophy, RoyalCrown (previews in `docs/previews/meshes/`)
- [x] Samples uploaded (asset IDs in `assets/meshes/uploaded.json`)
- [ ] Samples checked in Studio (right way up, facing forward, right colors)
- [ ] Remaining 18 items
- [ ] Shop props (register, safe, chandelier, lamps, benches, fountain...)
