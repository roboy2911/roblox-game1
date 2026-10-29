"""Sitting teddy bear with a bow tie, facing -Y. About 1.9 studs tall."""


def build(lib):
    Look = lib.Look
    fur = Look("Fur", (170, 110, 65), "Fabric", roughness=1.0)
    light = Look("LightFur", (230, 190, 145), "Fabric", roughness=1.0)
    dark = Look("Nose", (40, 28, 25), roughness=0.3)
    bow = Look("Bow", (220, 50, 70), "Fabric", roughness=0.8)
    stitch = Look("Stitch", (90, 55, 35), "Fabric")

    # Body and tummy
    lib.sphere(fur, 0.5, pos=(0, 0.05, 0.62), scale=(1.0, 0.88, 1.08))
    lib.sphere(light, 0.33, pos=(0, -0.22, 0.56), scale=(1.0, 0.6, 1.1))

    # Legs sticking forward, with paw pads
    for side in (-1, 1):
        lib.sphere(fur, 0.22, pos=(side * 0.3, -0.25, 0.22), scale=(1.0, 1.5, 0.95), rot=(0, 0, side * -12))
        lib.sphere(light, 0.15, pos=(side * 0.33, -0.55, 0.24), scale=(1.0, 0.3, 1.0))
        # Arms resting on the sides
        lib.sphere(fur, 0.17, pos=(side * 0.5, -0.12, 0.72), scale=(1.0, 1.0, 1.7), rot=(25, side * 20, 0))
        lib.sphere(light, 0.1, pos=(side * 0.56, -0.3, 0.48), scale=(1.0, 0.5, 1.0))

    # Head with ears, snout, nose, eyes and a little smile
    lib.sphere(fur, 0.4, pos=(0, -0.02, 1.38), scale=(1.05, 0.95, 0.95))
    for side in (-1, 1):
        lib.sphere(fur, 0.15, pos=(side * 0.32, 0.02, 1.72), scale=(1.0, 0.55, 1.0))
        lib.sphere(light, 0.09, pos=(side * 0.32, -0.05, 1.71), scale=(1.0, 0.4, 1.0))
        lib.sphere(dark, 0.05, pos=(side * 0.15, -0.37, 1.48), segments=16, rings=10)
        lib.sphere(lib.WHITE, 0.016, pos=(side * 0.15 + 0.015, -0.415, 1.5), segments=8, rings=6)
    lib.sphere(light, 0.19, pos=(0, -0.32, 1.3), scale=(1.1, 0.8, 0.8))
    lib.sphere(dark, 0.07, pos=(0, -0.47, 1.35), scale=(1.3, 0.8, 0.9), segments=16, rings=10)
    lib.tube(dark, [(-0.07, -0.47, 1.24), (0.0, -0.48, 1.21), (0.07, -0.47, 1.24)], 0.01)
    lib.rod(stitch, (0, -0.48, 1.29), (0, -0.48, 1.22), 0.01, verts=6)

    # Bow tie
    for side in (-1, 1):
        lib.slab(bow, [(0, -0.03), (side * 0.2, -0.1), (side * 0.22, 0.1), (0, 0.03)], 0.06,
                 pos=(0, -0.38, 1.02), rot=(90, 0, 0), bevel=0.02)
    lib.sphere(bow, 0.05, pos=(0, -0.41, 1.02), segments=12, rings=8)
