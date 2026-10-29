"""Shop prop: wall lantern next to the door, hanging out toward -Y.
Origin: where the bracket meets the wall/pillar (back center of the wall plate)."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    gold = lib.GOLD
    glass = Look("Glass", (255, 240, 200), "Glass", roughness=0.0, transparency=0.45, reflectance=0.1)
    glow = Look("Glow", (255, 225, 160), "Neon", emission=6)
    dark = lib.DARK

    # Wall plate and curly bracket arm
    lib.box(gold, (0.4, 0.08, 0.7), pos=(0, -0.04, 0), bevel=0.03)
    lib.tube(gold, [(0, -0.05, 0.1), (0, -0.4, 0.2), (0, -0.85, 0.15), (0, -0.9, 0.0)], 0.05)
    lib.tube(gold, [(0, -0.05, -0.2), (0, -0.3, -0.25), (0, -0.45, -0.1), (0, -0.4, 0.05)], 0.03)

    # Lantern: cap, glass box with gold corner posts, a glowing bulb, bottom finial
    cy = -0.9
    lib.lathe(gold, [(0.0, 0.0), (0.5, 0.0), (0.52, 0.05), (0.2, 0.25), (0.06, 0.3), (0.0, 0.32)],
              pos=(0, cy, -0.2), segments=4, rot=(0, 0, 45), smooth=False)
    lib.box(glass, (0.6, 0.6, 0.85), pos=(0, cy, -0.65), bevel=0.01)
    for x in (-0.3, 0.3):
        for y in (-0.3, 0.3):
            lib.box(gold, (0.06, 0.06, 0.9), pos=(x, cy + y, -0.65), bevel=0.01)
    lib.sphere(glow, 0.2, pos=(0, cy, -0.62), scale=(1.0, 1.0, 1.3))
    lib.box(gold, (0.72, 0.72, 0.1), pos=(0, cy, -1.1), bevel=0.03)
    lib.lathe(gold, [(0.0, 0.0), (0.2, 0.0), (0.12, -0.12), (0.03, -0.25), (0.0, -0.28)],
              pos=(0, cy, -1.14), segments=16)
    lib.cylinder(dark, 0.05, 0.12, pos=(0, cy, -0.2), verts=8)
