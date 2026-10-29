"""Shop prop: service bell on the counter. Origin: bottom center."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    wood = Look("Wood", (85, 55, 40), "Wood", roughness=0.4)
    gold = lib.GOLD

    lib.lathe(wood, [(0.0, 0.0), (0.5, 0.0), (0.52, 0.04), (0.5, 0.16), (0.46, 0.2), (0.0, 0.2)], segments=48)
    lib.lathe(gold, [(0.0, 0.2), (0.42, 0.2), (0.43, 0.24), (0.4, 0.34), (0.32, 0.5), (0.18, 0.6), (0.0, 0.63)],
              segments=48)
    lib.cylinder(gold, 0.04, 0.12, pos=(0, 0, 0.69), verts=12)
    lib.lathe(gold, [(0.0, 0.0), (0.1, 0.0), (0.11, 0.03), (0.08, 0.06), (0.0, 0.07)], pos=(0, 0, 0.74), segments=24)
