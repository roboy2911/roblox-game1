"""Desk lamp with a jointed arm, shade facing -Y. About 1.8 studs tall."""


def build(lib):
    Look = lib.Look
    blue = Look("Paint", (60, 140, 220), roughness=0.3)
    steel = lib.STEEL
    dark = lib.DARK
    bulb = Look("Bulb", (255, 225, 160), "Neon", emission=4)

    # Heavy round base with a switch
    lib.lathe(blue, [(0.0, 0.0), (0.48, 0.0), (0.5, 0.04), (0.46, 0.12), (0.2, 0.16), (0.0, 0.16)], segments=48)
    lib.cylinder(dark, 0.06, 0.06, pos=(0.25, -0.2, 0.17), verts=16)
    lib.cylinder(steel, 0.09, 0.14, pos=(0, 0.15, 0.22), verts=20)

    # Lower arm leaning back, upper arm reaching forward, with joints and springs
    base_joint = (0, 0.15, 0.3)
    elbow = (0, 0.32, 1.2)
    head = (0, -0.55, 1.55)
    for p in (base_joint, elbow):
        lib.sphere(dark, 0.08, pos=p, segments=16, rings=10)
    for dx in (-0.05, 0.05):
        lib.rod(steel, (dx, 0.15, 0.3), (dx, 0.32, 1.2), 0.022)
        lib.rod(steel, (dx, 0.32, 1.2), (dx, -0.48, 1.52), 0.022)
    lib.tube(steel, [(0.09, 0.2, 0.45), (0.11, 0.25, 0.75), (0.09, 0.29, 1.05)], 0.012)
    lib.tube(steel, [(0.09, 0.2, 1.3), (0.11, -0.05, 1.4), (0.09, -0.3, 1.47)], 0.012)

    # Cone shade tilted down, with the bulb peeking out
    shade = [(0.08, 0.0), (0.12, 0.04), (0.18, 0.18), (0.32, 0.4), (0.36, 0.48), (0.34, 0.48), (0.3, 0.41),
             (0.16, 0.2), (0.1, 0.06), (0.0, 0.05)]
    lib.lathe(blue, shade, pos=head, rot=(130, 0, 0), segments=40, closed=True)
    lib.sphere(dark, 0.07, pos=head, segments=16, rings=10)
    lib.sphere(bulb, 0.14, pos=(0, -0.72, 1.36), segments=20, rings=12)
