"""Shop prop: cash register on the counter. Display faces customers (-Y). Origin: bottom center.
Parts named "Accent" are painted in each shop's own color."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    accent = Look("Accent", (140, 80, 220), roughness=0.3)
    gold = lib.GOLD
    dark = lib.DARK
    keycap = Look("Keys", (245, 240, 230), roughness=0.3)
    display = Look("Display", (110, 255, 170), "Neon", emission=3)
    paper = Look("Paper", (250, 250, 245), roughness=0.8)

    # Base drawer with a gold handle, then the main body
    lib.box(dark, (2.6, 2.0, 0.42), pos=(0, 0, 0.21), bevel=0.06, bevel_segments=3)
    lib.box(accent, (2.4, 0.06, 0.3), pos=(0, -1.01, 0.22), bevel=0.03)
    lib.box(gold, (0.6, 0.08, 0.06), pos=(0, -1.06, 0.24), bevel=0.02)
    lib.box(accent, (2.5, 1.9, 0.6), pos=(0, 0.0, 0.72), bevel=0.12, bevel_segments=4)
    lib.box(gold, (2.54, 1.94, 0.05), pos=(0, 0, 0.44), bevel=0.015)

    # Sloped keyboard on the owner's side (+Y)
    lib.box(dark, (2.1, 1.0, 0.12), pos=(0, 0.4, 1.06), rot=(-14, 0, 0), bevel=0.04)
    for row in range(4):
        for col in range(6):
            x = -0.85 + col * 0.34
            y = 0.05 + row * 0.22
            z = 1.16 + (0.4 - y) * 0.25 + 0.02
            look = gold if col == 5 else keycap
            lib.cylinder(look, 0.07, 0.06, pos=(x, y, z), rot=(-14, 0, 0), verts=16, bevel=0.015)

    # Pop-up display facing customers, with a gold frame
    lib.box(accent, (0.25, 0.25, 0.5), pos=(0, -0.55, 1.2), bevel=0.06)
    lib.box(dark, (1.8, 0.25, 0.9), pos=(0, -0.55, 1.75), bevel=0.08, bevel_segments=3)
    lib.box(gold, (1.86, 0.2, 0.96), pos=(0, -0.52, 1.75), bevel=0.04)
    lib.box(display, (1.5, 0.05, 0.62), pos=(0, -0.69, 1.75), bevel=0.01)

    # Receipt printer on the side with a curl of paper
    lib.box(dark, (0.4, 0.5, 0.28), pos=(1.0, -0.4, 1.12), bevel=0.06)
    lib.tube(paper, [(0.98, -0.6, 1.25), (0.98, -0.75, 1.32), (0.98, -0.85, 1.2), (0.98, -0.8, 1.05)], 0.012,
             )
