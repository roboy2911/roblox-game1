"""Shop prop: the pawnbroker sign (three gold balls on a bracket), reaching out toward -Y.
Origin: where the bracket meets the wall."""

KEEP_ORIGIN = True


def build(lib):
    gold = lib.GOLD
    shiny = lib.Look("Balls", (255, 200, 60), "Metal", metallic=1.0, roughness=0.12, reflectance=0.3)

    # Wall plate, arm with a curly brace underneath
    lib.box(gold, (0.6, 0.1, 1.2), pos=(0, -0.05, -0.2), bevel=0.04)
    lib.box(gold, (0.3, 3.0, 0.3), pos=(0, -1.5, 0), bevel=0.08, bevel_segments=3)
    lib.tube(gold, [(0, -0.1, -0.7), (0, -0.6, -0.55), (0, -1.2, -0.2), (0, -1.8, -0.15)], 0.06)
    lib.sphere(gold, 0.18, pos=(0, -3.05, 0))

    # Hanging rod, crossbar, and the three balls
    lib.rod(gold, (0, -2.7, -0.1), (0, -2.7, -1.1), 0.08)
    lib.box(gold, (2.2, 0.22, 0.22), pos=(0, -2.7, -1.1), bevel=0.08, bevel_segments=3)
    for x in (-1.1, 1.1):
        lib.sphere(gold, 0.13, pos=(x, -2.7, -1.1))
    for x, z in ((-0.7, -1.9), (0.7, -1.9), (0.0, -3.25)):
        top = z + 0.65
        lib.rod(gold, (x * 0.9, -2.7, -1.15), (x, -2.7, top), 0.04, verts=8)
        lib.sphere(shiny, 0.65, pos=(x, -2.7, z), segments=40, rings=20)
