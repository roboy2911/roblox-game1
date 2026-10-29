"""Town prop: park bench with cast-iron sides and wooden slats. People sitting face -Y.
Origin: bottom center."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    wood = Look("Wood", (150, 100, 60), "Wood", roughness=0.5)
    iron = Look("Iron", (45, 45, 55), "Metal", metallic=0.7, roughness=0.4)
    gold = lib.GOLD

    # Two cast-iron sides with armrests (seen from the side: front is -Y)
    side = [(-0.9, 0.0), (-0.65, 0.0), (-0.45, 1.45), (0.55, 1.45), (0.75, 0.0), (1.0, 0.0), (0.8, 1.5),
            (1.05, 3.6), (0.85, 3.6), (0.62, 1.7), (-0.6, 1.7), (-0.75, 2.3), (-0.95, 2.35), (-0.8, 1.5)]
    for x in (-2.2, 2.2):
        lib.slab(iron, side, 0.18, pos=(x, 0, 0), rot=(90, 0, 90), bevel=0.04, sharp=True)
        lib.tube(iron, [(x, -0.95, 2.3), (x, -0.3, 2.45), (x, 0.4, 2.3), (x, 0.75, 2.4)], 0.07)
        lib.sphere(gold, 0.1, pos=(x, -0.98, 2.33))

    # Seat slats and back slats
    for y in (-0.6, -0.2, 0.2, 0.55):
        lib.box(wood, (5.0, 0.32, 0.12), pos=(0, y, 1.62), bevel=0.04)
    for k, z in enumerate((2.15, 2.6, 3.05, 3.45)):
        y = 0.68 + (z - 1.7) * 0.11
        lib.box(wood, (5.0, 0.12, 0.3), pos=(0, y, z), rot=(-6, 0, 0), bevel=0.04)
