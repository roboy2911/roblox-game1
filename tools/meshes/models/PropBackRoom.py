"""The back room (Bigger shop upgrade), behind the STAFF ONLY door. Same coordinates as
PropShopExterior (shop center at ground level): room inside x -7..13, z 17..32, floor top at 1.
The display cases and wall shelf in it are separate props. Origin: the shop's center."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    rbox = lib.rbox
    cream = Look("Wall", (250, 240, 220), roughness=0.7)
    trim = Look("Trim", (236, 224, 200), roughness=0.6)
    marble = Look("Marble", (240, 240, 245), "Marble", roughness=0.25)
    dark_marble = Look("DarkMarble", (45, 45, 60), "Marble", roughness=0.25)
    wood = Look("DarkWood", (85, 55, 40), "Wood", roughness=0.45)
    wood_light = Look("PanelWood", (110, 72, 50), "Wood", roughness=0.45)
    gold = lib.GOLD
    roof = Look("Roof", (70, 65, 90), "Slate", roughness=0.8)
    accent = Look("Accent", (140, 80, 220), roughness=0.4)
    glow = Look("Glow", (255, 225, 160), "Neon", emission=5)
    rug = Look("AccentRug", (140, 80, 220), "Fabric", roughness=1.0)
    rug_gold = Look("RugGold", (255, 196, 54), "Fabric", roughness=1.0)

    # Floor with checkered tiles
    rbox(marble, (22, 1, 16), (3, 0.5, 25), bevel=0.04)
    for ix in range(5):
        for iz in range(4):
            if (ix + iz) % 2 == 0:
                rbox(dark_marble, (3.9, 0.06, 3.6), (-5 + ix * 4, 1.02, 18.8 + iz * 3.65), bevel=0.02)
    # Runner rug from the door to the back
    rbox(rug_gold, (4.4, 0.08, 14.4), (3, 1.09, 24.6), bevel=0.03)
    rbox(rug, (3.8, 0.1, 13.8), (3, 1.1, 24.6), bevel=0.02)

    # Walls (sides and back), corner pilasters, colored base strip and gold roof trim outside
    for x in (-7.5, 13.5):
        rbox(cream, (1, 16, 16), (x, 9, 25), bevel=0.05)
    rbox(cream, (22, 16, 1), (3, 9, 32.5), bevel=0.05)
    for x in (-7.8, 13.8):
        rbox(trim, (1.4, 16.4, 1.4), (x, 9.2, 32.8), bevel=0.1)
        rbox(accent, (0.3, 1.2, 16), (x - 0.15 if x < 0 else x + 0.15, 0.8, 25), bevel=0.06)
        rbox(gold, (1.2, 0.4, 16.4), (x + (0.2 if x < 0 else -0.2), 18.2, 25), bevel=0.12, bevel_segments=3)
    rbox(accent, (22.6, 1.2, 0.3), (3, 0.8, 33.15), bevel=0.06)
    rbox(gold, (22.4, 0.4, 1.2), (3, 18.2, 32.6), bevel=0.12, bevel_segments=3)

    # Ceiling, roof and a light
    rbox(cream, (20, 0.2, 15), (3, 16.9, 24.5), bevel=0.0)
    rbox(roof, (22.4, 1, 16.6), (3, 17.5, 25.1), bevel=0.15, bevel_segments=2)
    rbox(gold, (4.4, 0.25, 4.4), (3, 16.72, 24.5), bevel=0.08)
    rbox(glow, (3.8, 0.2, 3.8), (3, 16.62, 24.5), bevel=0.05)

    # Wood panels on the lower walls with a gold rail, crown molding at the top
    for x, sx in ((-6.9, 1), (12.9, -1)):
        rbox(wood, (0.2, 4, 15), (x, 3, 24.5), bevel=0.02)
        rbox(gold, (0.4, 0.3, 15), (x + sx * 0.1, 5.15, 24.5), bevel=0.12, bevel_segments=3)
        rbox(trim, (0.6, 0.6, 15), (x + sx * 0.2, 16.5, 24.5), bevel=0.2, bevel_segments=3)
        for k in range(4):
            rbox(wood_light, (0.12, 2.4, 2.9), (x + sx * 0.14, 3.1, 18.8 + k * 3.65), bevel=0.06, bevel_segments=2)
    rbox(wood, (20, 4, 0.2), (3, 3, 31.9), bevel=0.02)
    rbox(gold, (20, 0.3, 0.4), (3, 5.15, 31.8), bevel=0.12, bevel_segments=3)
    rbox(trim, (20, 0.6, 0.6), (3, 16.5, 31.7), bevel=0.2, bevel_segments=3)
    rbox(trim, (20, 0.6, 0.6), (3, 16.5, 17.3), bevel=0.2, bevel_segments=3)
