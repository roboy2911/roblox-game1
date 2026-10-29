"""Shop prop: gold chandelier with candle bulbs and glass drops.
Origin: the hook at the top (hangs down from z = 0)."""

import math

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    gold = lib.GOLD
    glass = Look("Crystal", (200, 235, 255), "Glass", roughness=0.0, transparency=0.3, reflectance=0.3)
    glow = Look("Glow", (255, 225, 160), "Neon", emission=6)
    candle = Look("Candle", (250, 245, 235), roughness=0.4)

    # Ceiling cup and chain
    lib.lathe(gold, [(0.0, 0.0), (0.5, 0.0), (0.4, -0.15), (0.1, -0.25), (0.0, -0.25)], segments=32)
    for k in range(6):
        z = -0.35 - k * 0.22
        lib.torus(gold, 0.08, 0.025, pos=(0, 0, z), rot=(90 if k % 2 else 0, 0, 90 if k % 2 else 0),
                  major_seg=12, minor_seg=6)

    # Center column turned on a lathe, ending in a big crystal ball
    col = [(0.0, -1.6), (0.12, -1.62), (0.2, -1.75), (0.12, -1.9), (0.3, -2.1), (0.42, -2.35), (0.3, -2.55),
           (0.12, -2.65), (0.08, -2.8), (0.0, -2.82)]
    lib.lathe(gold, col, segments=32)
    lib.sphere(glass, 0.3, pos=(0, 0, -3.05))

    # Six curved arms, each with a candle, a glowing bulb and a hanging crystal
    for k in range(6):
        a = 2 * math.pi * k / 6
        c, s = math.cos(a), math.sin(a)
        lib.tube(gold, [(0.25 * c, 0.25 * s, -2.3), (1.0 * c, 1.0 * s, -2.65), (1.8 * c, 1.8 * s, -2.45),
                        (2.0 * c, 2.0 * s, -2.15)], 0.05)
        lib.lathe(gold, [(0.0, 0.0), (0.2, 0.02), (0.22, 0.08), (0.08, 0.08), (0.0, 0.08)],
                  pos=(2.0 * c, 2.0 * s, -2.15), segments=20)
        lib.cylinder(candle, 0.07, 0.35, pos=(2.0 * c, 2.0 * s, -1.9), verts=16)
        lib.sphere(glow, 0.12, pos=(2.0 * c, 2.0 * s, -1.62), scale=(1.0, 1.0, 1.5), segments=16, rings=10)
        lib.gem(glass, 0.08, pos=(1.4 * c, 1.4 * s, -2.85), rot=(180, 0, 0), facets=6, height=2.0)
    # A ring of crystal drops between the arms
    for k in range(12):
        a = 2 * math.pi * (k + 0.5) / 12
        lib.gem(glass, 0.06, pos=(0.85 * math.cos(a), 0.85 * math.sin(a), -2.75), rot=(180, 0, 0), facets=6,
                height=2.0)
    lib.torus(gold, 0.85, 0.025, pos=(0, 0, -2.58), major_seg=48, minor_seg=6)
