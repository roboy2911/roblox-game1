"""The checkout: a closed-in island of counters in the middle of the shop, with the gate in its
back side (the gate itself is separate in the game, so it can swing). Shop coordinates, origin
at the shop's center (see ShopBuilder.luau): front counter x -10..10, z 3..6; side counters
x +-(7..10), z 6..17; back counters x +-(2..7), z 14..17. Counter tops are 4 up from the floor.
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

    def counter(x0, x1, z0, z1, faces):
        """A counter piece over x0..x1, z0..z1; `faces` = outward sides that get colored panels
        ("front" = -Z, "back" = +Z, "left" = -X, "right" = +X)."""
        cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
        w, d = x1 - x0, z1 - z0
        rbox(marble, (w, 3.6, d), (cx, 2.8, cz), bevel=0.08, bevel_segments=2)
        rbox(gold, (w + 0.1, 0.4, d + 0.1), (cx, 1.2, cz), bevel=0.1, bevel_segments=2)
        rbox(dark_marble, (w + 0.3, 0.4, d + 0.3), (cx, 4.8, cz), bevel=0.15, bevel_segments=3)
        for face in faces:
            along_x = face in ("front", "back")
            length = w if along_x else d
            count = max(1, round(length / 6))
            step = length / count
            for k in range(count):
                a = (x0 if along_x else z0) + step * (k + 0.5)
                if along_x:
                    z = z0 - 0.05 if face == "front" else z1 + 0.05
                    rbox(gold, (step - 0.9, 2.6, 0.12), (a, 2.9, z), bevel=0.05)
                    rbox(accent, (step - 1.3, 2.2, 0.12), (a, 2.9, z + (-0.07 if face == "front" else 0.07)),
                         bevel=0.06, bevel_segments=2)
                    rbox(gold, (w + 0.3, 0.2, 0.2), (cx, 4.55, z0 - 0.15 if face == "front" else z1 + 0.15), bevel=0.08)
                else:
                    x = x0 - 0.05 if face == "left" else x1 + 0.05
                    rbox(gold, (0.12, 2.6, step - 0.9), (x, 2.9, a), bevel=0.05)
                    rbox(accent, (0.12, 2.2, step - 1.3), (x + (-0.07 if face == "left" else 0.07), 2.9, a),
                         bevel=0.06, bevel_segments=2)
                    rbox(gold, (0.2, 0.2, d + 0.3), (x0 - 0.15 if face == "left" else x1 + 0.15, 4.55, cz), bevel=0.08)

    counter(-10, 10, 3, 6, ("front",))  # front counter: customers stand here, at the register
    counter(-10, -7, 6, 17, ("left",))
    counter(7, 10, 6, 17, ("right",))
    counter(-10, -2, 14, 17, ("back",))  # back counters, with the gate between them (x -2..2)
    counter(2, 10, 14, 17, ("back",))
    # Corner posts with gold caps, and posts either side of the gate
    for x, z in ((-10, 3), (10, 3), (-10, 17), (10, 17), (-2, 17), (2, 17)):
        rbox(marble, (0.8, 4.4, 0.8), (x, 3.2, z), bevel=0.12, bevel_segments=2)
        lib.sphere(gold, 0.35, pos=lib.R(x, 5.6, z), segments=16, rings=10)

    # Owner's side of the front counter: open shelves
    rbox(wood, (16.5, 2.4, 0.15), (0, 1.9, 6.1), bevel=0.02)
    rbox(wood, (16.5, 0.12, 1.0), (0, 1.9, 6.6), bevel=0.02)
    for x in (-5.5, 0, 5.5):
        rbox(wood, (0.15, 2.4, 1.0), (x, 1.9, 6.6), bevel=0.02)
