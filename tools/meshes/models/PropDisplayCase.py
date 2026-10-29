"""Glass display case: marble base, colored display cloth, glass box with gold posts.
Long side runs front-to-back. Origin: bottom center. The display surface is 2.7 studs up.
Parts named "Accent..." take the shop's own color."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    rbox = lib.rbox
    marble = Look("Marble", (240, 240, 245), "Marble", roughness=0.25)
    gold = lib.GOLD
    cloth = Look("AccentCloth", (140, 80, 220), "Fabric", roughness=1.0)
    glass = Look("Glass", (190, 230, 255), "Glass", roughness=0.0, transparency=0.75, reflectance=0.2)

    # Base: marble with sunken side panels, gold kick and feet
    rbox(marble, (3, 2.6, 8), (0, 1.3, 0), bevel=0.08, bevel_segments=2)
    rbox(gold, (3.2, 0.3, 8.2), (0, 0.15, 0), bevel=0.08)
    for s in (-1, 1):
        for z in (-2, 2):
            rbox(gold, (0.06, 1.6, 3.2), (s * 1.52, 1.4, z), bevel=0.02)
            rbox(marble, (0.08, 1.4, 3.0), (s * 1.54, 1.4, z), bevel=0.04)
    rbox(gold, (3.1, 0.12, 8.1), (0, 2.6, 0), bevel=0.04)

    # Display cloth and the glass box
    rbox(cloth, (2.8, 0.1, 7.8), (0, 2.65, 0), bevel=0.03)
    rbox(glass, (2.9, 2.35, 7.9), (0, 3.9, 0), bevel=0.02)
    for x in (-1.4, 1.4):
        for z in (-3.9, 3.9):
            rbox(gold, (0.2, 2.4, 0.2), (x, 3.9, z), bevel=0.06)
            lib.sphere(gold, 0.16, pos=lib.R(x, 5.2, z), segments=12, rings=8)
        rbox(gold, (0.2, 0.2, 8), (x, 5.1, 0), bevel=0.06)
    for z in (-3.9, 3.9):
        rbox(gold, (3, 0.2, 0.2), (0, 5.1, z), bevel=0.06)
