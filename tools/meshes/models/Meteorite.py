"""Lumpy meteorite with glowing purple crystals, on a marble stand. About 2 studs tall."""

import random


def build(lib):
    Look = lib.Look
    rock = Look("Rock", (70, 60, 80), "Basalt", roughness=0.9)
    crust = Look("Crust", (45, 38, 52), "Basalt", roughness=1.0)
    glow = Look("Crystal", (170, 90, 255), "Neon", emission=4)
    marble = Look("Marble", (40, 40, 52), "Marble", roughness=0.25)
    gold = lib.GOLD

    # Round marble stand with gold rings
    lib.lathe(marble, [(0.0, 0.0), (0.62, 0.0), (0.64, 0.05), (0.58, 0.14), (0.5, 0.2), (0.48, 0.28),
                       (0.0, 0.28)], segments=56)
    lib.torus(gold, 0.6, 0.02, pos=(0, 0, 0.12), major_seg=56, minor_seg=8)
    lib.torus(gold, 0.49, 0.02, pos=(0, 0, 0.28), major_seg=56, minor_seg=8)

    # The rock itself, with darker scorched lumps
    lib.blob(rock, 0.55, (0, 0, 0.85), (1.0, 0.9, 0.95), seed=3.1, subdivisions=4)
    lib.blob(crust, 0.3, (0.32, -0.15, 1.12), (1.0, 0.9, 0.8), seed=7.4)
    lib.blob(crust, 0.26, (-0.3, 0.2, 0.68), (1.0, 1.0, 0.8), seed=1.7)

    # Crystal clusters poking out
    random.seed(4)
    for cx, cy, cz, tilt_x, tilt_y in ((0.12, -0.42, 1.0, 50, 10), (-0.38, -0.25, 1.05, 35, -40),
                                         (0.3, 0.25, 1.35, -30, 30), (-0.1, 0.05, 1.42, -5, -10),
                                         (0.45, -0.1, 0.72, 20, 60)):
        for k in range(3):
            h = random.uniform(0.18, 0.34)
            r = random.uniform(0.05, 0.08)
            prof = [(0.0, -0.05), (r, 0.0), (r, h * 0.7), (0.0, h)]
            lib.lathe(glow, prof, pos=(cx + random.uniform(-0.05, 0.05), cy + random.uniform(-0.05, 0.05), cz),
                      rot=(tilt_x + random.uniform(-15, 15), tilt_y + random.uniform(-15, 15), 0), segments=6,
                      smooth=False)
