"""Street piece: 8 studs of sidewalk with paving stones and a rounded curb on the street side.
Runs along X; the curb (street side) faces -Y. Origin: bottom center of the sidewalk
(the sidewalk is 8 wide, 0.5 tall). Lined up in a row by the game."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    rbox = lib.rbox
    grout = Look("Grout", (170, 170, 178), "Concrete", roughness=0.9)
    stone = Look("Paving", (210, 210, 216), "Concrete", roughness=0.8)
    stone2 = Look("PavingDark", (192, 192, 200), "Concrete", roughness=0.8)
    curb = Look("Curb", (240, 240, 245), "Marble", roughness=0.4)

    rbox(grout, (8, 0.45, 8), (0, 0.225, 0), bevel=0.0)
    # Paving stones in a running-bond pattern (rows along the street)
    for row in range(4):
        z = -2.4 + row * 1.75
        offset = 0.0 if row % 2 == 0 else 1.0
        for k in range(5):
            x = -4 + offset + k * 2.0
            x0, x1 = max(x - 1.0, -4.0), min(x + 1.0, 4.0)
            if x1 - x0 < 0.3:
                continue
            look = stone2 if (row + k) % 3 == 0 else stone
            rbox(look, (x1 - x0 - 0.08, 0.1, 1.67), ((x0 + x1) / 2, 0.47, z), bevel=0.03, bevel_segments=1)
    # Curb along the street edge, with a little gutter in front
    rbox(curb, (8, 0.6, 0.7), (0, 0.27, -3.75), bevel=0.15, bevel_segments=3)
    rbox(grout, (8, 0.05, 0.35), (0, 0.05, -4.25), bevel=0.0)
