"""Worn-out leather boot, toe facing -Y. About 1.9 studs tall."""


def build(lib):
    Look = lib.Look
    leather = Look("Leather", (112, 74, 44), "Leather", roughness=0.8)
    worn = Look("Worn", (150, 105, 65), "Leather", roughness=0.9)
    sole = Look("Sole", (45, 38, 34), roughness=0.9)
    lace = Look("Laces", (225, 212, 188), "Fabric", roughness=1.0)
    eyelet = lib.STEEL

    # Sole and heel: a footprint shape seen from above
    foot = [(0.0, -1.0), (0.3, -0.9), (0.42, -0.5), (0.38, 0.1), (0.34, 0.6), (0.3, 0.92),
            (0.0, 1.0), (-0.3, 0.92), (-0.34, 0.6), (-0.4, 0.1), (-0.44, -0.5), (-0.3, -0.9)]
    lib.slab(sole, foot, 0.16, pos=(0, 0, 0.08), bevel=0.04)
    lib.box(sole, (0.6, 0.55, 0.18), pos=(0, 0.66, 0.22), bevel=0.05)

    # Foot of the boot with a round toe cap
    lib.box(leather, (0.78, 1.5, 0.62), pos=(0, 0.1, 0.45), bevel=0.24, bevel_segments=5)
    lib.sphere(leather, 0.42, pos=(0, -0.6, 0.4), scale=(0.95, 1.05, 0.72))
    lib.sphere(worn, 0.3, pos=(0, -0.78, 0.45), scale=(1.0, 0.7, 0.6))  # scuffed toe

    # Shaft (the tall part) leaning back slightly, with a folded top
    lib.box(leather, (0.78, 0.8, 1.15), pos=(0, 0.45, 1.15), rot=(-6, 0, 0), bevel=0.2, bevel_segments=5)
    lib.box(worn, (0.84, 0.86, 0.2), pos=(0, 0.5, 1.72), rot=(-6, 0, 0), bevel=0.08, bevel_segments=3)
    # Pull tab at the back
    lib.slab(leather, [(-0.1, 0), (0.1, 0), (0.08, 0.22), (-0.08, 0.22)], 0.04,
             pos=(0, 0.88, 1.72), rot=(84, 0, 0), bevel=0.015)

    # Tongue and laces up the front
    lib.box(worn, (0.36, 0.08, 0.9), pos=(0, 0.02, 1.15), rot=(-20, 0, 0), bevel=0.04)
    for k in range(5):
        z = 0.72 + k * 0.17
        y = -0.12 + k * 0.045
        for side in (-1, 1):
            lib.cylinder(eyelet, 0.03, 0.02, pos=(side * 0.2, y - 0.06, z), rot=(90, 0, 0), verts=10)
        lib.rod(lace, (-0.2, y - 0.08, z), (0.2, y - 0.08, z + 0.15), 0.018, verts=6)
        lib.rod(lace, (0.2, y - 0.08, z), (-0.2, y - 0.08, z + 0.15), 0.018, verts=6)
    # Loose lace hanging down
    lib.tube(lace, [(0.2, -0.0, 1.55), (0.32, -0.12, 1.3), (0.36, -0.2, 0.95)], 0.018)

