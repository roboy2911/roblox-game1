"""Vintage film camera (SLR), lens facing -Y. About 1.0 studs tall."""


def build(lib):
    Look = lib.Look
    body = Look("Body", (40, 40, 46), roughness=0.4)
    leather = Look("Leather", (110, 75, 50), "Leather", roughness=0.85)
    chrome = Look("Chrome", (200, 205, 215), "Metal", metallic=1.0, roughness=0.2, reflectance=0.2)
    glass = Look("Lens", (110, 160, 230), "Glass", roughness=0.05, reflectance=0.3)
    red = Look("Red", (220, 50, 50), roughness=0.3)

    # Body: chrome top and bottom plates with leather in between
    lib.box(chrome, (1.3, 0.5, 0.16), pos=(0, 0, 0.08), bevel=0.05, bevel_segments=3)
    lib.box(leather, (1.28, 0.5, 0.42), pos=(0, 0, 0.36), bevel=0.04, bevel_segments=3)
    lib.box(chrome, (1.3, 0.5, 0.18), pos=(0, 0, 0.66), bevel=0.05, bevel_segments=3)
    # Viewfinder hump on top
    prism = [(-0.28, 0.0), (0.28, 0.0), (0.18, 0.26), (-0.18, 0.26)]
    lib.slab(body, prism, 0.44, pos=(0, 0.02, 0.74), rot=(90, 0, 0), bevel=0.03, sharp=True)
    lib.box(chrome, (0.2, 0.03, 0.05), pos=(0, -0.21, 0.88), bevel=0.01)

    # Dials, shutter button and film lever
    for x in (-0.42, 0.42):
        lib.lathe(chrome, [(0.0, 0.0), (0.13, 0.0), (0.13, 0.1), (0.11, 0.12), (0.0, 0.12)], pos=(x, 0.0, 0.75),
                  segments=32)
    lib.cylinder(red, 0.04, 0.04, pos=(0.42, 0.0, 0.89), verts=16)
    lib.box(chrome, (0.3, 0.06, 0.03), pos=(0.5, 0.12, 0.89), rot=(0, 0, -20), bevel=0.01)
    # Strap lugs
    for x in (-0.66, 0.66):
        lib.torus(chrome, 0.05, 0.012, pos=(x, 0, 0.62), rot=(0, 90, 0), major_seg=16, minor_seg=6)

    # Lens: chrome mount, black barrel with grip rings, glass at the front
    lib.cylinder(chrome, 0.3, 0.06, pos=(0, -0.28, 0.4), rot=(90, 0, 0), verts=40)
    barrel = [(0.25, 0.0), (0.25, 0.08), (0.27, 0.09), (0.27, 0.16), (0.25, 0.17), (0.25, 0.22), (0.27, 0.23),
              (0.27, 0.3), (0.25, 0.31), (0.26, 0.36), (0.22, 0.38), (0.0, 0.38)]
    lib.lathe(body, barrel, pos=(0, -0.3, 0.4), rot=(90, 0, 0), segments=40, cap_bottom=False)
    lib.torus(chrome, 0.245, 0.012, pos=(0, -0.62, 0.4), rot=(90, 0, 0), major_seg=40, minor_seg=6)
    lib.sphere(glass, 0.2, pos=(0, -0.64, 0.4), scale=(1.0, 0.25, 1.0))
    lib.box(lib.WHITE, (0.03, 0.01, 0.06), pos=(0, -0.53, 0.66), bevel=0)
