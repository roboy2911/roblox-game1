"""Acoustic guitar standing upright, front facing -Y. About 4.7 studs tall."""

def build(lib):
    Look = lib.Look
    spruce = Look("Top", (232, 180, 110), "Wood", roughness=0.45)
    sides = Look("Body", (150, 85, 40), "Wood", roughness=0.4)
    rosewood = Look("Rosewood", (55, 35, 28), "Wood", roughness=0.6)
    binding = Look("Binding", (240, 230, 210))
    tortoise = Look("Pickguard", (90, 45, 25), roughness=0.3)
    nickel = lib.STEEL

    # Body outline (right half, bottom to top), mirrored for the left half
    half = [(0.0, 0.05), (0.45, 0.1), (0.72, 0.42), (0.76, 0.88), (0.64, 1.32), (0.5, 1.56),
            (0.56, 1.82), (0.58, 2.1), (0.46, 2.38), (0.2, 2.5)]
    outline = [(0.0, 0.05)] + half[1:] + [(0.0, 2.52)] + [(-x, y) for x, y in reversed(half[1:])]

    # Back + sides (darker wood), then the lighter spruce top, then a white edge binding
    lib.slab(sides, outline, 0.4, pos=(0, 0.02, 0), rot=(90, 0, 0), bevel=0.06)
    lib.slab(spruce, [(x * 0.97, 0.05 + (y - 0.05) * 0.985) for x, y in outline], 0.04,
             pos=(0, -0.19, 0.02), rot=(90, 0, 0), bevel=0.01)
    lib.slab(binding, [(x * 1.0, y) for x, y in outline], 0.025, pos=(0, -0.175, 0), rot=(90, 0, 0), bevel=0.008)

    # Sound hole with rosette rings
    lib.cylinder(lib.DARK, 0.22, 0.02, pos=(0, -0.205, 1.72), rot=(90, 0, 0), verts=40)
    lib.torus(rosewood, 0.27, 0.022, pos=(0, -0.21, 1.72), rot=(90, 0, 0))
    lib.torus(binding, 0.31, 0.012, pos=(0, -0.21, 1.72), rot=(90, 0, 0))

    # Teardrop pickguard below-right of the hole
    guard = [(0.0, 0.0), (0.16, 0.08), (0.22, 0.28), (0.12, 0.42), (-0.02, 0.34), (-0.06, 0.15)]
    lib.slab(tortoise, guard, 0.01, pos=(0.2, -0.215, 1.2), rot=(90, 0, 0), bevel=0.003)

    # Bridge with white saddle and pins
    lib.slab(rosewood, [(-0.34, 0), (0.34, 0), (0.3, 0.13), (-0.3, 0.13)], 0.06,
             pos=(0, -0.225, 0.62), rot=(90, 0, 0), bevel=0.015, sharp=True)
    lib.box(binding, (0.36, 0.025, 0.025), pos=(0, -0.265, 0.72), bevel=0.005)
    for i in range(6):
        lib.sphere(binding, 0.018, pos=(-0.125 + i * 0.05, -0.255, 0.66), segments=10, rings=6)

    # Neck, fretboard (runs onto the body), frets, dots, nut
    lib.box(sides, (0.22, 0.13, 1.74), pos=(0, -0.12, 3.32), bevel=0.05, bevel_segments=4)
    lib.box(rosewood, (0.25, 0.03, 2.04), pos=(0, -0.215, 3.17), bevel=0.008)
    nut_z, scale = 4.18, 3.3
    frets = [nut_z - scale * (1 - 2 ** (-n / 12)) for n in range(1, 19)]
    for z in frets:
        if z > 2.18:
            lib.box(nickel, (0.25, 0.015, 0.012), pos=(0, -0.232, z), bevel=0)
    for n in (3, 5, 7, 9, 12):
        z = (frets[n - 2] + frets[n - 1]) / 2
        lib.sphere(binding, 0.018, pos=(0, -0.229, z), scale=(1, 0.3, 1), segments=10, rings=6)
    lib.box(binding, (0.25, 0.035, 0.03), pos=(0, -0.235, nut_z), bevel=0.005)

    # Headstock, tilted back a little, with tuners
    head = [(-0.13, 0.0), (0.13, 0.0), (0.17, 0.25), (0.18, 0.5), (0.0, 0.58), (-0.18, 0.5), (-0.17, 0.25)]
    lib.slab(rosewood, head, 0.08, pos=(0, -0.12, 4.2), rot=(80, 0, 0), bevel=0.02)
    for side in (-1, 1):
        for k, z in enumerate((4.33, 4.48, 4.63)):
            lib.cylinder(nickel, 0.03, 0.14, pos=(side * 0.22, -0.12 + (z - 4.2) * 0.17, z), rot=(0, 90, 0), verts=10)
            lib.sphere(binding, 0.05, pos=(side * 0.31, -0.12 + (z - 4.2) * 0.17, z), scale=(0.5, 0.9, 1.2),
                       segments=12, rings=8)

    # Strings from bridge to nut
    for i in range(6):
        x_bridge = -0.125 + i * 0.05
        x_nut = -0.08 + i * 0.032
        lib.rod(nickel, (x_bridge, -0.28, 0.72), (x_nut, -0.255, nut_z), 0.004 + 0.0015 * (5 - i), verts=6)
