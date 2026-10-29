"""Shop prop: round gold wall clock. Face points -Y.
Origin: center of the back, where it touches the wall."""

import math

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    gold = lib.GOLD
    face = Look("Face", (250, 248, 240), roughness=0.3)
    dark = lib.DARK
    glass = Look("Glass", (220, 240, 255), "Glass", roughness=0.0, transparency=0.7, reflectance=0.25)

    lib.cylinder(gold, 1.3, 0.2, pos=(0, -0.1, 0), rot=(90, 0, 0), verts=64, bevel=0.06)
    lib.torus(gold, 1.2, 0.08, pos=(0, -0.22, 0), rot=(90, 0, 0), major_seg=64, minor_seg=12)
    lib.cylinder(face, 1.12, 0.02, pos=(0, -0.21, 0), rot=(90, 0, 0), verts=64, bevel=0)
    for k in range(60):
        a = 2 * math.pi * k / 60
        big = k % 5 == 0
        r = 0.95 if big else 1.0
        size = (0.05, 0.02, 0.2) if big else (0.02, 0.02, 0.07)
        lib.box(dark, size, pos=(r * math.sin(a), -0.225, r * math.cos(a)), rot=(0, math.degrees(a), 0), bevel=0)
    # Hands showing ten past ten, and a gold center cap
    lib.box(dark, (0.08, 0.02, 0.6), pos=(-0.26, -0.24, 0.15), rot=(0, -60, 0), bevel=0.01)
    lib.box(dark, (0.05, 0.02, 0.9), pos=(0.39, -0.245, 0.225), rot=(0, 60, 0), bevel=0.01)
    lib.cylinder(gold, 0.07, 0.04, pos=(0, -0.26, 0), rot=(90, 0, 0), verts=16)
    lib.sphere(glass, 1.13, pos=(0, -0.22, 0), scale=(1.0, 0.1, 1.0), segments=48, rings=16)
