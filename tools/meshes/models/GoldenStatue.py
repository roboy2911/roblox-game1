"""Golden statue of a figure holding up a torch, on a marble pedestal, facing -Y. About 3 studs tall."""


def build(lib):
    Look = lib.Look
    gold = Look("Gold", (255, 196, 54), "Metal", metallic=1.0, roughness=0.2, reflectance=0.25)
    marble = Look("Marble", (240, 240, 245), "Marble", roughness=0.25)
    flame = Look("Flame", (255, 160, 40), "Neon", emission=5)

    # Stepped marble pedestal with gold trim
    lib.box(marble, (1.3, 1.3, 0.16), pos=(0, 0, 0.08), bevel=0.04, bevel_segments=3)
    lib.box(marble, (1.1, 1.1, 0.42), pos=(0, 0, 0.37), bevel=0.04, bevel_segments=3)
    lib.box(gold, (1.18, 1.18, 0.05), pos=(0, 0, 0.6), bevel=0.015)
    lib.box(gold, (0.5, 0.02, 0.16), pos=(0, -0.555, 0.37), bevel=0.005)

    # Long robe: a lathe shape that flares at the feet, with folds
    robe = [(0.0, 0.62), (0.36, 0.62), (0.34, 0.75), (0.27, 1.1), (0.24, 1.45), (0.25, 1.7), (0.27, 1.9),
            (0.22, 2.05), (0.12, 2.12), (0.0, 2.14)]
    lib.lathe(gold, robe, segments=40)
    for k in range(7):
        x = -0.24 + k * 0.08
        lib.tube(gold, [(x, -0.25 - abs(x) * 0.1, 0.66), (x * 0.85, -0.23, 1.1), (x * 0.7, -0.21, 1.45)], 0.025)
    # Sash across the chest
    lib.tube(gold, [(-0.24, -0.15, 1.6), (0.0, -0.27, 1.8), (0.24, -0.12, 2.02)], 0.035)

    # Head with a spiked crown
    lib.cylinder(gold, 0.07, 0.12, pos=(0, 0, 2.18), verts=16)
    lib.sphere(gold, 0.15, pos=(0, -0.02, 2.36), scale=(0.9, 1.0, 1.1))
    lib.torus(gold, 0.13, 0.025, pos=(0, -0.02, 2.44), major_seg=24, minor_seg=8)
    import math
    for k in range(7):
        a = math.radians(-90 - 75 + k * 25)
        lib.lathe(gold, [(0.03, 0.0), (0.0, 0.16)], pos=(0.13 * math.cos(a), -0.02 + 0.13 * math.sin(a), 2.44),
                  rot=(-30 * math.sin(a), 30 * math.cos(a), 0), segments=8)

    # Raised right arm holding the torch, left arm holding a tablet
    lib.tube(gold, [(0.22, -0.02, 1.95), (0.32, -0.04, 2.25), (0.34, -0.05, 2.6)], 0.06)
    lib.sphere(gold, 0.07, pos=(0.34, -0.05, 2.62))
    lib.lathe(gold, [(0.03, 0.0), (0.05, 0.12), (0.09, 0.2), (0.1, 0.24), (0.0, 0.24)],
              pos=(0.34, -0.05, 2.6), segments=24)
    lib.sphere(flame, 0.1, pos=(0.34, -0.05, 2.92), scale=(1.0, 1.0, 1.6))
    lib.tube(gold, [(-0.22, -0.02, 1.95), (-0.3, -0.1, 1.7), (-0.2, -0.24, 1.55)], 0.055)
    lib.box(gold, (0.2, 0.08, 0.3), pos=(-0.22, -0.28, 1.62), rot=(15, 0, -20), bevel=0.02)
