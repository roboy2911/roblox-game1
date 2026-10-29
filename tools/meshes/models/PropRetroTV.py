"""Shop prop: retro TV on a wooden cabinet, screen facing -Y. Origin: bottom center."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    wood = Look("Wood", (150, 100, 60), "Wood", roughness=0.45)
    dark_wood = Look("DarkWood", (85, 55, 40), "Wood", roughness=0.5)
    case = Look("Case", (95, 85, 80), roughness=0.4)
    screen = Look("Screen", (40, 70, 95), "Glass", roughness=0.05, reflectance=0.2)
    chrome = lib.STEEL
    dark = lib.DARK

    # Cabinet on tapered legs with two doors
    for x in (-1.75, 1.75):
        for y in (-1.0, 1.0):
            lib.rod(dark_wood, (x * 0.95, y * 0.9, 0.0), (x, y, 0.5), 0.09)
    lib.box(wood, (4.0, 2.5, 2.0), pos=(0, 0, 1.5), bevel=0.08, bevel_segments=3)
    lib.box(dark_wood, (4.1, 2.6, 0.12), pos=(0, 0, 2.5), bevel=0.04)
    for x in (-0.97, 0.97):
        lib.box(dark_wood, (1.8, 0.06, 1.6), pos=(x, -1.26, 1.5), bevel=0.03)
        lib.box(wood, (1.6, 0.06, 1.4), pos=(x, -1.29, 1.5), bevel=0.04)
        lib.sphere(chrome, 0.07, pos=(x * 0.15, -1.36, 1.5), segments=12, rings=8)

    # Chunky TV with a rounded screen and a side panel of knobs
    lib.box(case, (3.4, 2.2, 2.6), pos=(0, 0.05, 3.86), bevel=0.3, bevel_segments=5)
    lib.box(dark, (2.4, 0.1, 1.95), pos=(-0.35, -1.06, 3.9), bevel=0.25, bevel_segments=4)
    lib.sphere(screen, 1.0, pos=(-0.35, -0.96, 3.9), scale=(1.12, 0.12, 0.9))
    lib.box(dark_wood, (0.7, 0.06, 2.0), pos=(1.25, -1.07, 3.9), bevel=0.05)
    for z in (4.4, 3.85):
        lib.cylinder(chrome, 0.17, 0.12, pos=(1.25, -1.12, z), rot=(90, 0, 0), verts=24, bevel=0.03)
        lib.box(dark, (0.04, 0.02, 0.2), pos=(1.25, -1.19, z + 0.05), bevel=0)
    for k in range(5):
        lib.box(dark, (0.45, 0.02, 0.03), pos=(1.25, -1.1, 3.2 + k * 0.08), bevel=0)

    # Rabbit-ear antenna
    lib.sphere(dark, 0.22, pos=(0, 0.2, 5.16), scale=(1.4, 1.0, 0.6))
    for side in (-1, 1):
        lib.rod(chrome, (side * 0.1, 0.2, 5.2), (side * 0.75, 0.25, 6.6), 0.03, verts=8)
        lib.sphere(chrome, 0.05, pos=(side * 0.75, 0.25, 6.6), segments=10, rings=6)
