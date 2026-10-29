"""Gold wristwatch wrapped around a display pillow, face toward -Y. About 1.3 studs tall."""

import math


def build(lib):
    Look = lib.Look
    gold = lib.GOLD
    marble = Look("Marble", (40, 40, 52), "Marble", roughness=0.25)
    velvet = Look("Velvet", (130, 30, 50), "Fabric", roughness=0.9)
    face = Look("Face", (250, 248, 240), roughness=0.3)
    hands = lib.DARK
    glass = Look("Crystal", (210, 235, 255), "Glass", roughness=0.02, transparency=0.6, reflectance=0.3)

    # Marble stand and velvet pillow
    lib.box(marble, (0.9, 0.7, 0.18), pos=(0, 0, 0.09), bevel=0.04, bevel_segments=3)
    lib.box(gold, (0.92, 0.72, 0.03), pos=(0, 0, 0.19), bevel=0.01)
    lib.box(velvet, (0.42, 0.5, 0.62), pos=(0, 0.05, 0.52), bevel=0.15, bevel_segments=5)

    # Bracelet: gold links wrapped around the pillow
    cy, cz, ry, rz = 0.05, 0.6, 0.29, 0.36
    for k in range(26):
        a = 2 * math.pi * k / 26
        if math.cos(a) > 0.8:
            continue  # the watch itself sits here, at the front
        y, z = cy - ry * math.cos(a), cz + rz * math.sin(a)
        tilt = math.degrees(math.atan2(-ry * math.sin(a), rz * math.cos(a)))  # follow the curve
        lib.box(gold, (0.3, 0.04, 0.07), pos=(0, y, z), rot=(tilt, 0, 0), bevel=0.012)

    # Watch case on the front of the pillow
    wy, wz = cy - ry - 0.04, cz
    lib.cylinder(gold, 0.24, 0.08, pos=(0, wy, wz), rot=(90, 0, 0), verts=48, bevel=0.025)
    lib.torus(gold, 0.22, 0.025, pos=(0, wy - 0.045, wz), rot=(90, 0, 0), major_seg=48, minor_seg=10)
    lib.cylinder(face, 0.2, 0.02, pos=(0, wy - 0.04, wz), rot=(90, 0, 0), verts=48)
    lib.sphere(glass, 0.2, pos=(0, wy - 0.05, wz), scale=(1.0, 0.15, 1.0))
    # Hour marks and hands
    for k in range(12):
        a = 2 * math.pi * k / 12
        size = (0.018, 0.01, 0.05) if k % 3 == 0 else (0.01, 0.01, 0.03)
        lib.box(gold if k % 3 == 0 else hands, size, pos=(0.16 * math.sin(a), wy - 0.052, wz + 0.16 * math.cos(a)),
                rot=(0, math.degrees(a), 0), bevel=0)
    lib.box(hands, (0.018, 0.008, 0.1), pos=(0.03, wy - 0.056, wz + 0.035), rot=(0, 40, 0), bevel=0)
    lib.box(hands, (0.012, 0.008, 0.15), pos=(-0.05, wy - 0.058, wz - 0.045), rot=(0, 130, 0), bevel=0)
    lib.cylinder(gold, 0.018, 0.02, pos=(0, wy - 0.062, wz), rot=(90, 0, 0), verts=12)
    # Winding crown on the side
    lib.cylinder(gold, 0.035, 0.07, pos=(0.27, wy, wz), rot=(0, 90, 0), verts=16, bevel=0.01)
