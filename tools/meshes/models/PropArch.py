"""Town piece: the "PAWN STREET" arch: two marble pillars and a frame for the sign (the sign itself,
with its text, is a part in the game). Faces both ways. Origin: bottom center between the pillars."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    R, rbox = lib.R, lib.rbox
    marble = Look("Marble", (240, 240, 245), "Marble", roughness=0.25)
    gold = lib.GOLD

    for s in (-1, 1):
        x = s * 14
        rbox(marble, (2.8, 0.6, 2.8), (x, 0.3, 0), bevel=0.1, bevel_segments=2)
        rbox(marble, (2.4, 0.5, 2.4), (x, 0.85, 0), bevel=0.1, bevel_segments=2)
        shaft = [(0.0, 1.1), (1.05, 1.1), (0.92, 1.4), (0.9, 2.0), (0.85, 8.0), (0.8, 13.6), (0.95, 13.85),
                 (0.0, 13.85)]
        lib.lathe(marble, shaft, pos=R(x, 0, 0), segments=20, smooth=False)
        lib.lathe(gold, [(0.0, 13.85), (0.9, 13.85), (1.1, 14.1), (1.3, 14.35), (0.0, 14.35)], pos=R(x, 0, 0),
                  segments=32)
        rbox(gold, (2.6, 0.5, 2.6), (x, 14.55, 0), bevel=0.12, bevel_segments=2)
        lib.sphere(gold, 0.45, pos=R(s * 15.5, 17.95, 0), segments=20, rings=10)
    # Gold frame around the sign (the sign part is 31 x 3 x 1, centered 15.8 up)
    for y in (14.15, 17.45):
        rbox(gold, (31.4, 0.4, 1.2), (0, y, 0), bevel=0.12, bevel_segments=3)
    # A curved crest on top
    crest = [(-6.0, 0.0), (6.0, 0.0), (4.5, 0.9), (2.0, 1.6), (0.0, 1.8), (-2.0, 1.6), (-4.5, 0.9)]
    lib.slab(gold, crest, 0.5, pos=R(0, 17.6, 0), rot=(90, 0, 0), bevel=0.1)
    lib.sphere(gold, 0.45, pos=R(0, 19.75, 0), segments=20, rings=10)
