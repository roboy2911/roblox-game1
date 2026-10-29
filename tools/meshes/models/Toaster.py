"""Retro chrome toaster with toast popping up, front facing -Y. About 1.5 studs tall."""


def build(lib):
    Look = lib.Look
    chrome = Look("Chrome", (200, 205, 215), "Metal", metallic=1.0, roughness=0.15, reflectance=0.25)
    dark = lib.DARK
    toast = Look("Toast", (215, 160, 90), roughness=0.9)
    crust = Look("Crust", (150, 90, 45), roughness=0.9)
    red = Look("Red", (215, 50, 50), roughness=0.35)

    # Rounded body on a dark base with little feet
    lib.box(chrome, (1.4, 0.8, 1.0), pos=(0, 0, 0.62), bevel=0.28, bevel_segments=6)
    lib.box(dark, (1.5, 0.9, 0.12), pos=(0, 0, 0.16), bevel=0.05, bevel_segments=3)
    for x in (-0.6, 0.6):
        for y in (-0.32, 0.32):
            lib.cylinder(dark, 0.06, 0.1, pos=(x, y, 0.05), verts=12)
    # Red stripe around the middle
    lib.box(red, (1.42, 0.82, 0.08), pos=(0, 0, 0.55), bevel=0.04)

    # Two slots in the top, each with a slice of toast
    for y in (-0.17, 0.17):
        lib.box(dark, (0.92, 0.14, 0.04), pos=(0, y, 1.11), bevel=0.02)
        bread = [(-0.36, 0.0), (0.36, 0.0), (0.38, 0.38), (0.3, 0.52), (0.15, 0.56), (0.0, 0.5),
                 (-0.15, 0.56), (-0.3, 0.52), (-0.38, 0.38)]
        lib.slab(crust, bread, 0.1, pos=(0, y, 0.82), rot=(90, 0, 0), bevel=0.02)
        lib.slab(toast, [(x * 0.88, 0.02 + yy * 0.9) for x, yy in bread], 0.104,
                 pos=(0, y, 0.82), rot=(90, 0, 0), bevel=0.01)

    # Lever on the side and a browning dial on the front
    lib.box(dark, (0.06, 0.12, 0.5), pos=(0.73, 0, 0.7), bevel=0.02)
    lib.box(red, (0.14, 0.22, 0.1), pos=(0.8, 0, 0.8), bevel=0.04, bevel_segments=3)
    lib.cylinder(dark, 0.09, 0.06, pos=(-0.4, -0.42, 0.45), rot=(90, 0, 0), verts=24)
    lib.box(red, (0.03, 0.02, 0.12), pos=(-0.4, -0.46, 0.47), bevel=0.005)
