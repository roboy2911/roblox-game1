"""Mystery painting (sunset over the sea) on a wooden easel, front facing -Y. About 2.6 studs tall."""

import math


def build(lib):
    Look = lib.Look
    wood = Look("Easel", (110, 70, 45), "Wood", roughness=0.5)
    gold = lib.GOLD
    sky = Look("Sky", (255, 165, 90), roughness=0.9)
    sky_top = Look("SkyTop", (190, 110, 170), roughness=0.9)
    sun = Look("Sun", (255, 235, 130), roughness=0.9)
    sea = Look("Sea", (55, 105, 185), roughness=0.9)
    hill = Look("Hills", (70, 60, 95), roughness=0.9)
    boat = Look("Boat", (40, 30, 40), roughness=0.9)

    # Easel: two front legs, one back leg, a ledge for the painting
    lib.rod(wood, (-0.75, 0.1, 0.0), (-0.12, 0.45, 2.6), 0.05)
    lib.rod(wood, (0.75, 0.1, 0.0), (0.12, 0.45, 2.6), 0.05)
    lib.rod(wood, (0.0, 1.1, 0.0), (0.0, 0.47, 2.45), 0.045)
    lib.box(wood, (1.9, 0.32, 0.08), pos=(0, 0.02, 0.62), bevel=0.02)
    lib.box(wood, (1.9, 0.06, 0.1), pos=(0, -0.16, 0.68), bevel=0.02)
    lib.box(wood, (0.3, 0.12, 0.1), pos=(0, 0.4, 2.12), bevel=0.02)

    # Painting leans back a little, resting on the ledge
    tilt = 8
    t = math.radians(tilt)

    def at(x, z, d):  # point on the painting, z up from its bottom, d toward the viewer
        return (x, -0.06 + z * math.sin(t) - d * math.cos(t), 0.68 + z * math.cos(t) + d * math.sin(t))

    w, h = 1.7, 1.35
    # Ornate gold frame: four rounded bars plus corner knobs
    for z in (0.0, h):
        lib.box(gold, (w + 0.14, 0.12, 0.14), pos=at(0, z, 0), rot=(-tilt, 0, 0), bevel=0.04, bevel_segments=3)
    for x in (-w / 2, w / 2):
        lib.box(gold, (0.14, 0.12, h), pos=at(x, h / 2, 0), rot=(-tilt, 0, 0), bevel=0.04, bevel_segments=3)
        for z in (0.0, h):
            lib.sphere(gold, 0.1, pos=at(x, z, 0.03), segments=16, rings=10)
    lib.sphere(gold, 0.12, pos=at(0, h + 0.08, 0.02), scale=(1.6, 0.6, 1.0))

    # The picture: sky bands, sun, sea, hills and a little sailboat
    lib.box(sky_top, (w - 0.1, 0.02, h * 0.35), pos=at(0, h * 0.8, 0.0), rot=(-tilt, 0, 0), bevel=0)
    lib.box(sky, (w - 0.1, 0.02, h * 0.35), pos=at(0, h * 0.5, 0.0), rot=(-tilt, 0, 0), bevel=0)
    lib.cylinder(sun, 0.2, 0.02, pos=at(0.3, h * 0.42, 0.02), rot=(90 - tilt, 0, 0), verts=32, bevel=0)
    lib.box(sea, (w - 0.1, 0.03, h * 0.36), pos=at(0, h * 0.2, 0.02), rot=(-tilt, 0, 0), bevel=0)
    hills = [(-0.8, 0.0), (0.1, 0.0), (-0.05, 0.12), (-0.3, 0.28), (-0.55, 0.22), (-0.8, 0.32)]
    lib.slab(hill, hills, 0.02, pos=at(0, h * 0.37, 0.035), rot=(90 - tilt, 0, 0), bevel=0, sharp=True)
    lib.slab(boat, [(-0.12, 0.0), (0.12, 0.0), (0.16, 0.05), (-0.16, 0.05)], 0.02,
             pos=at(0.45, h * 0.18, 0.045), rot=(90 - tilt, 0, 0), bevel=0, sharp=True)
    lib.slab(lib.WHITE, [(0.0, 0.05), (0.1, 0.06), (0.0, 0.3)], 0.02,
             pos=at(0.45, h * 0.18, 0.045), rot=(90 - tilt, 0, 0), bevel=0, sharp=True)
