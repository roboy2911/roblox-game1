"""Town piece: 8 studs of trimmed hedge (3 tall, 2 deep). Runs along X.
Origin: bottom center. Lined up in a row by the game."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    leaf = Look("Leaf", (60, 150, 65), "Grass", roughness=0.8)
    leaf2 = Look("LeafLight", (80, 175, 75), "Grass", roughness=0.8)

    lib.box(leaf, (8.0, 1.8, 2.7), pos=(0, 0, 1.4), bevel=0.45, bevel_segments=3)
    for k in range(5):
        x = -3.4 + k * 1.7
        lib.blob(leaf2 if k % 2 else leaf, 0.85, pos=(x, 0, 2.3), scale=(1.25, 1.1, 0.85), seed=k * 1.9,
                 lumps=0.18, detail=0.1, subdivisions=2)
