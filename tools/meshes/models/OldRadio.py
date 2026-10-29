"""Wooden cathedral radio from the 1930s, front facing -Y. About 1.4 studs tall."""


def build(lib):
    Look = lib.Look
    wood = Look("Wood", (150, 95, 55), "Wood", roughness=0.45)
    dark_wood = Look("DarkWood", (85, 52, 35), "Wood", roughness=0.5)
    cloth = Look("Cloth", (220, 195, 150), "Fabric", roughness=1.0)
    gold = lib.GOLD
    dial = Look("DialFace", (250, 235, 200), roughness=0.4)
    dark = lib.DARK

    # Arched cabinet seen from the front
    arch = [(-0.62, 0.0), (0.62, 0.0), (0.62, 0.7), (0.56, 1.0), (0.38, 1.25), (0.0, 1.38),
            (-0.38, 1.25), (-0.56, 1.0), (-0.62, 0.7)]
    lib.slab(wood, arch, 0.6, pos=(0, 0.0, 0.08), rot=(90, 0, 0), bevel=0.05)
    lib.box(dark_wood, (1.36, 0.68, 0.1), pos=(0, 0, 0.05), bevel=0.03)
    # Darker wood trim around the front
    lib.slab(dark_wood, [(x * 1.02, y * 1.01) for x, y in arch], 0.03,
             pos=(0, -0.29, 0.07), rot=(90, 0, 0), bevel=0.01)
    lib.slab(wood, [(x * 0.92, 0.04 + y * 0.95) for x, y in arch], 0.04,
             pos=(0, -0.31, 0.08), rot=(90, 0, 0), bevel=0.012)

    # Speaker cloth behind wooden fretwork
    grille = [(-0.38, 0.0), (0.38, 0.0), (0.38, 0.38), (0.3, 0.56), (0.0, 0.66), (-0.3, 0.56), (-0.38, 0.38)]
    lib.slab(cloth, grille, 0.02, pos=(0, -0.335, 0.62), rot=(90, 0, 0), bevel=0.004)
    for x in (-0.19, 0.0, 0.19):
        lib.box(dark_wood, (0.04, 0.03, 0.6), pos=(x, -0.35, 0.92 + (0.06 if x == 0 else 0)), bevel=0.01)
    lib.tube(dark_wood, [(-0.33, -0.35, 1.0), (0.0, -0.35, 1.18), (0.33, -0.35, 1.0)], 0.02)

    # Gold dial window and two knobs
    lib.cylinder(gold, 0.15, 0.04, pos=(0, -0.34, 0.38), rot=(90, 0, 0), verts=32)
    lib.cylinder(dial, 0.12, 0.045, pos=(0, -0.345, 0.38), rot=(90, 0, 0), verts=32)
    lib.box(dark, (0.012, 0.01, 0.1), pos=(0.02, -0.37, 0.41), rot=(0, 25, 0), bevel=0)
    for x in (-0.36, 0.36):
        lib.cylinder(dark_wood, 0.08, 0.08, pos=(x, -0.36, 0.3), rot=(90, 0, 0), bevel=0.02)
        lib.cylinder(gold, 0.03, 0.09, pos=(x, -0.365, 0.3), rot=(90, 0, 0), verts=12)
