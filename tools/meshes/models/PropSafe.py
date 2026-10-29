"""Shop prop: big steel safe with gold bars on top. Door faces -Y. Origin: bottom center."""

import math

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    body = Look("Body", (45, 45, 55), "Metal", metallic=0.8, roughness=0.35, reflectance=0.05)
    door = Look("Door", (75, 75, 90), "Metal", metallic=0.8, roughness=0.3, reflectance=0.05)
    gold = Look("Gold", (255, 196, 54), "Metal", metallic=1.0, roughness=0.2, reflectance=0.25)
    steel = lib.STEEL
    dark = lib.DARK

    # Body on four stubby feet
    for x in (-1.7, 1.7):
        for y in (-1.4, 1.4):
            lib.lathe(dark, [(0.0, 0.0), (0.25, 0.0), (0.2, 0.25), (0.0, 0.25)], pos=(x, y, 0), segments=16)
    lib.box(body, (4.0, 3.5, 4.75), pos=(0, 0, 2.62), bevel=0.25, bevel_segments=4)

    # Thick door with a gold border, hinges, dial and spoked handle
    lib.box(door, (3.3, 0.25, 4.0), pos=(0, -1.8, 2.62), bevel=0.12, bevel_segments=3)
    lib.box(gold, (3.42, 0.18, 4.12), pos=(0, -1.76, 2.62), bevel=0.06)
    for z in (1.3, 3.9):
        lib.cylinder(steel, 0.12, 0.55, pos=(1.7, -1.85, z), verts=16, bevel=0.03)
    lib.cylinder(gold, 0.55, 0.12, pos=(0, -1.97, 3.3), rot=(90, 0, 0), verts=48, bevel=0.03)
    lib.cylinder(dark, 0.42, 0.14, pos=(0, -1.99, 3.3), rot=(90, 0, 0), verts=48, bevel=0.02)
    for k in range(20):
        a = 2 * math.pi * k / 20
        lib.box(gold, (0.03, 0.03, 0.08), pos=(0.36 * math.cos(a), -2.06, 3.3 + 0.36 * math.sin(a)),
                rot=(0, -math.degrees(a) + 90, 0), bevel=0)
    lib.cylinder(steel, 0.18, 0.2, pos=(0, -2.06, 3.3), rot=(90, 0, 0), verts=24, bevel=0.04)
    lib.cylinder(steel, 0.12, 0.2, pos=(-0.9, -1.98, 2.2), rot=(90, 0, 0), verts=20, bevel=0.03)
    for k in range(3):
        a = math.radians(90 + k * 120)
        lib.rod(steel, (-0.9, -2.08, 2.2), (-0.9 + 0.55 * math.cos(a), -2.08, 2.2 + 0.55 * math.sin(a)), 0.05)
        lib.sphere(steel, 0.09, pos=(-0.9 + 0.55 * math.cos(a), -2.08, 2.2 + 0.55 * math.sin(a)))

    # Gold bars stacked on top
    bar = [(-0.6, 0.0), (0.6, 0.0), (0.5, 0.45), (-0.5, 0.45)]
    for x, z in ((-0.6, 5.0), (0.65, 5.0), (0.02, 5.45)):
        lib.slab(gold, bar, 0.62, pos=(x, -0.2, z), rot=(90, 0, 0), bevel=0.05, sharp=True)
