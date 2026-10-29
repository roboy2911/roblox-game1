"""Skateboard on its wheels, nose pointing -Y. About 0.6 studs tall, 2.8 long."""


def build(lib):
    Look = lib.Look
    deck = Look("Deck", (255, 90, 60), "Wood", roughness=0.5)
    grip = Look("Grip", (35, 35, 40), "Sand", roughness=1.0)
    stripe = Look("Graphic", (255, 210, 60), roughness=0.5)
    metal = lib.STEEL
    wheel = Look("Wheel", (250, 240, 120), roughness=0.4)
    dark = lib.DARK

    # Deck: flat middle with kicked-up nose and tail
    mid = [(-0.39, -0.9), (0.39, -0.9), (0.39, 0.9), (-0.39, 0.9)]
    lib.slab(deck, mid, 0.08, pos=(0, 0, 0.42), bevel=0.02, sharp=True)
    lib.slab(grip, [(x * 0.97, y) for x, y in mid], 0.012, pos=(0, 0, 0.465), bevel=0.003, sharp=True)
    end = [(-0.39, 0.0), (0.39, 0.0), (0.37, 0.25), (0.26, 0.42), (0.0, 0.47), (-0.26, 0.42), (-0.37, 0.25)]
    for sign, rot_z in ((-1, 180), (1, 0)):
        lib.slab(deck, end, 0.08, pos=(0, sign * 0.88, 0.43), rot=(18, 0, rot_z), bevel=0.02)
        lib.slab(grip, [(x * 0.95, y * 0.95) for x, y in end], 0.012,
                 pos=(0, sign * 0.88, 0.473), rot=(18, 0, rot_z), bevel=0.003)
    # Graphic on the edge of the deck
    lib.box(stripe, (0.8, 1.4, 0.02), pos=(0, 0, 0.375), bevel=0.005)

    # Trucks and wheels
    for y in (-0.72, 0.72):
        lib.box(metal, (0.32, 0.36, 0.05), pos=(0, y, 0.355), bevel=0.01)
        lib.slab(metal, [(-0.1, 0.0), (0.1, 0.0), (0.06, 0.14), (-0.06, 0.14)], 0.14,
                 pos=(0, y, 0.2), rot=(90, 0, 0), bevel=0.02)
        lib.box(metal, (0.62, 0.1, 0.08), pos=(0, y, 0.19), bevel=0.03, bevel_segments=3)
        lib.cylinder(metal, 0.025, 0.86, pos=(0, y, 0.17), rot=(0, 90, 0), verts=10)
        for side in (-1, 1):
            lib.cylinder(wheel, 0.17, 0.15, pos=(side * 0.36, y, 0.17), rot=(0, 90, 0), bevel=0.04)
            lib.cylinder(dark, 0.07, 0.152, pos=(side * 0.36, y, 0.17), rot=(0, 90, 0), verts=16)
        for dx in (-0.1, 0.1):
            for dy in (-0.11, 0.11):
                lib.cylinder(metal, 0.018, 0.02, pos=(dx, y + dy, 0.48), verts=8)
