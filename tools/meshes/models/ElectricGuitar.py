"""Red electric guitar standing upright, front facing -Y. About 3.9 studs tall."""


def build(lib):
    Look = lib.Look
    red = Look("Paint", (210, 30, 50), roughness=0.15, reflectance=0.05)
    guard = lib.WHITE
    maple = Look("Maple", (225, 185, 125), "Wood", roughness=0.4)
    dark = lib.DARK
    chrome = Look("Chrome", (200, 205, 215), "Metal", metallic=1.0, roughness=0.2, reflectance=0.2)

    # Double-cut body (the classic offset shape), bottom to top on the right, mirrored-ish on the left
    body = [(0.0, 0.0), (0.42, 0.06), (0.62, 0.3), (0.6, 0.62), (0.48, 0.86), (0.52, 1.1), (0.62, 1.4),
            (0.6, 1.62), (0.48, 1.62), (0.36, 1.38), (0.2, 1.22), (0.0, 1.22), (-0.2, 1.22), (-0.34, 1.36),
            (-0.46, 1.78), (-0.6, 1.8), (-0.62, 1.5), (-0.52, 1.12), (-0.5, 0.86), (-0.62, 0.6),
            (-0.62, 0.3), (-0.42, 0.06)]
    lib.slab(red, body, 0.28, pos=(0, 0, 0), rot=(90, 0, 0), bevel=0.06)
    pg = [(0.05, 0.2), (0.4, 0.3), (0.5, 0.62), (0.4, 0.92), (0.3, 1.16), (0.1, 1.2), (-0.25, 1.22),
          (-0.38, 1.12), (-0.3, 0.78), (-0.08, 0.6)]
    lib.slab(guard, pg, 0.02, pos=(0, -0.15, 0), rot=(90, 0, 0), bevel=0.006)

    # Three pickups, bridge, knobs and switch
    for z in (0.62, 0.86, 1.08):
        lib.box(lib.WHITE, (0.32, 0.04, 0.1), pos=(-0.02, -0.17, z), rot=(0, 8 if z < 0.7 else 0, 0), bevel=0.03)
        for k in range(6):
            lib.cylinder(chrome, 0.012, 0.01, pos=(-0.14 + k * 0.048, -0.19, z), rot=(90, 0, 0), verts=8)
    lib.box(chrome, (0.36, 0.05, 0.16), pos=(0, -0.17, 0.4), bevel=0.015)
    for x, z in ((0.32, 0.5), (0.36, 0.34), (0.28, 0.2)):
        lib.cylinder(lib.WHITE, 0.055, 0.06, pos=(x, -0.19, z), rot=(90, 0, 0), verts=20, bevel=0.015)
    lib.box(lib.WHITE, (0.03, 0.04, 0.08), pos=(0.38, -0.18, 0.75), rot=(0, 30, 0), bevel=0.01)
    lib.tube(chrome, [(0.42, -0.17, 0.42), (0.55, -0.24, 0.5), (0.6, -0.28, 0.6)], 0.012)  # whammy bar

    # Maple neck with fret dots, then the headstock with six tuners in a row
    lib.box(maple, (0.2, 0.1, 1.8), pos=(0, -0.1, 2.12), bevel=0.04, bevel_segments=3)
    lib.box(maple, (0.23, 0.03, 1.82), pos=(0, -0.165, 2.12), bevel=0.008)
    nut_z, scale = 3.02, 2.9
    for n in range(1, 22):
        z = nut_z - scale * (1 - 2 ** (-n / 12))
        if z > 1.24:
            lib.box(chrome, (0.23, 0.012, 0.012), pos=(0, -0.182, z), bevel=0)
    for n in (3, 5, 7, 9, 12):
        z = nut_z - scale * (1 - 2 ** (-(n - 0.5) / 12))
        lib.cylinder(dark, 0.018, 0.01, pos=(0, -0.182, z), rot=(90, 0, 0), verts=12)
    lib.box(lib.WHITE, (0.23, 0.035, 0.03), pos=(0, -0.18, nut_z), bevel=0.005)
    head = [(-0.11, 0.0), (0.11, 0.0), (0.16, 0.2), (0.15, 0.62), (0.08, 0.78), (-0.06, 0.74), (-0.14, 0.5),
            (-0.12, 0.2)]
    lib.slab(maple, head, 0.06, pos=(0, -0.12, 3.03), rot=(90, 0, 0), bevel=0.015)
    for k in range(6):
        z = 3.14 + k * 0.1
        lib.cylinder(chrome, 0.025, 0.05, pos=(-0.1 + 0.005 * k, -0.16, z), rot=(90, 0, 0), verts=12)
        lib.box(chrome, (0.1, 0.02, 0.05), pos=(-0.2, -0.08, z), bevel=0.01)

    # Strings
    for i in range(6):
        lib.rod(chrome, (-0.08 + i * 0.032, -0.2, 0.43), (-0.06 + i * 0.024, -0.2, nut_z), 0.004, verts=5)
