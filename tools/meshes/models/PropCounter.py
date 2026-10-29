"""Shop counter: marble body with colored panels, gold kick and edge, dark marble top.
Front (customer side) faces -Y. Origin: bottom center. The top surface is 4 studs up.
Parts named "Accent" take the shop's own color."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    rbox = lib.rbox
    marble = Look("Marble", (240, 240, 245), "Marble", roughness=0.25)
    dark_marble = Look("DarkMarble", (45, 45, 60), "Marble", roughness=0.2, reflectance=0.05)
    gold = lib.GOLD
    accent = Look("Accent", (140, 80, 220), roughness=0.35)
    wood = Look("DarkWood", (85, 55, 40), "Wood", roughness=0.45)

    # Body and gold kick plate
    rbox(marble, (18, 3.6, 3), (0, 1.8, 0), bevel=0.08, bevel_segments=2)
    rbox(gold, (18.2, 0.4, 3.2), (0, 0.2, 0), bevel=0.1, bevel_segments=2)
    rbox(gold, (18.1, 0.12, 3.1), (0, 3.3, 0), bevel=0.04)

    # Three colored panels on the front, each in a gold frame, with marble pilasters between
    for x in (-6, 0, 6):
        rbox(gold, (5.2, 2.6, 0.12), (x, 1.9, -1.53), bevel=0.05)
        rbox(accent, (4.8, 2.2, 0.12), (x, 1.9, -1.6), bevel=0.06, bevel_segments=2)
        lib.sphere(gold, 0.18, pos=lib.R(x, 1.9, -1.68), scale=(1.0, 0.5, 1.0), segments=16, rings=10)
    for x in (-8.8, -3, 3, 8.8):
        rbox(marble, (0.7, 3.0, 0.25), (x, 1.8, -1.55), bevel=0.08, bevel_segments=2)

    # Thick dark marble top with a rounded front edge and a gold strip under it
    rbox(dark_marble, (18.6, 0.4, 3.6), (0, 3.8, 0), bevel=0.15, bevel_segments=3)
    rbox(gold, (18.6, 0.2, 0.2), (0, 3.55, -1.85), bevel=0.08)

    # Owner's side: open shelves under the top
    rbox(wood, (16.5, 2.4, 0.15), (0, 1.9, 1.45), bevel=0.02)
    rbox(wood, (16.5, 0.12, 1.0), (0, 1.9, 1.0), bevel=0.02)
    for x in (-5.5, 0, 5.5):
        rbox(wood, (0.15, 2.4, 1.0), (x, 1.9, 1.0), bevel=0.02)
