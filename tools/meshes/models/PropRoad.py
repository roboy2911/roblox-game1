"""Street piece: 8 studs of road, 24 wide, with a dashed middle line, edge lines and gutters.
Runs along X. Origin: bottom center. Lined up in a row by the game."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    rbox = lib.rbox
    asphalt = Look("Asphalt", (60, 60, 72), "Asphalt", roughness=0.95)
    patch = Look("Patch", (52, 52, 63), "Asphalt", roughness=0.95)
    yellow = Look("Yellow", (255, 210, 60), roughness=0.6)
    white = Look("Line", (245, 245, 245), roughness=0.6)
    gutter = Look("Gutter", (150, 150, 158), "Concrete", roughness=0.9)

    rbox(asphalt, (8, 0.2, 22.6), (0, 0.1, 0), bevel=0.0)
    for s in (-1, 1):
        rbox(gutter, (8, 0.16, 0.7), (0, 0.08, s * 11.65), bevel=0.04)
        rbox(white, (8, 0.04, 0.35), (0, 0.215, s * 10.8), bevel=0.0)
    rbox(yellow, (4, 0.04, 0.5), (0, 0.215, 0), bevel=0.01)
    # A couple of worn patches so the road isn't perfectly flat-colored
    rbox(patch, (1.6, 0.02, 2.4), (2.1, 0.205, -5.5), bevel=0.0)
    rbox(patch, (2.2, 0.02, 1.3), (-2.4, 0.205, 6.0), bevel=0.0)
