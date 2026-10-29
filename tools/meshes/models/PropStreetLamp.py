"""Town prop: old-fashioned street lamp. The arm reaches out toward -Y.
Origin: bottom of the pole."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    iron = Look("Iron", (45, 45, 55), "Metal", metallic=0.7, roughness=0.4)
    gold = lib.GOLD
    glass = Look("Glass", (255, 240, 200), "Glass", roughness=0.0, transparency=0.4, reflectance=0.1)
    glow = Look("Glow", (255, 225, 160), "Neon", emission=8)

    # Base and fluted pole turned on a lathe
    lib.lathe(iron, [(0.0, 0.0), (0.75, 0.0), (0.75, 0.2), (0.6, 0.3), (0.55, 0.6), (0.35, 0.9), (0.28, 1.2),
                     (0.0, 1.2)], segments=8, smooth=False)
    lib.cylinder(iron, 0.22, 11.0, pos=(0, 0, 6.6), verts=16, bevel=0)
    lib.torus(gold, 0.3, 0.08, pos=(0, 0, 3.0), major_seg=24, minor_seg=8)
    lib.torus(gold, 0.27, 0.06, pos=(0, 0, 1.25), major_seg=24, minor_seg=8)
    lib.lathe(iron, [(0.0, 0.0), (0.3, 0.0), (0.35, 0.15), (0.0, 0.3)], pos=(0, 0, 12.0), segments=16)
    lib.sphere(gold, 0.18, pos=(0, 0, 12.45))

    # Curly arm out to the lantern
    lib.tube(iron, [(0, 0, 11.9), (0, -1.2, 12.35), (0, -2.6, 12.3), (0, -3.0, 12.05)], 0.12)
    lib.tube(iron, [(0, -0.05, 11.0), (0, -0.7, 11.2), (0, -1.0, 11.6), (0, -0.7, 11.9), (0, -0.5, 11.7)], 0.06)

    # Lantern: roof, glass with a glowing bulb, bottom
    ly = -3.0
    lib.lathe(iron, [(0.0, 0.0), (0.9, 0.0), (0.92, 0.08), (0.3, 0.45), (0.1, 0.55), (0.0, 0.6)],
              pos=(0, ly, 11.9), segments=6, smooth=False)
    lib.lathe(glass, [(0.0, 0.0), (0.45, 0.0), (0.7, 1.0), (0.0, 1.0)], pos=(0, ly, 10.9), segments=6, smooth=False,
              cap_top=True)
    lib.sphere(glow, 0.32, pos=(0, ly, 11.35), scale=(1.0, 1.0, 1.25))
    lib.lathe(iron, [(0.0, 0.0), (0.55, 0.0), (0.5, -0.15), (0.15, -0.3), (0.0, -0.35)], pos=(0, ly, 10.9),
              segments=6, smooth=False)
