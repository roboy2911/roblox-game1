"""Brass trumpet, bell facing -Y and valves on top. About 1.1 studs tall, 2.4 long."""


def build(lib):
    Look = lib.Look
    brass = Look("Brass", (240, 190, 70), "Metal", metallic=1.0, roughness=0.2, reflectance=0.2)
    pearl = Look("Pearl", (250, 245, 235), roughness=0.15, reflectance=0.1)
    silver = lib.STEEL

    # Three valve casings, each with a stem and a pearl finger button
    valve_ys = (-0.17, 0.0, 0.17)
    for y in valve_ys:
        lib.cylinder(brass, 0.07, 0.5, pos=(0, y, 0.6), bevel=0.01)
        lib.cylinder(brass, 0.085, 0.05, pos=(0, y, 0.87), bevel=0.01)
        lib.cylinder(brass, 0.08, 0.06, pos=(0, y, 0.33), bevel=0.015)
        lib.cylinder(silver, 0.018, 0.12, pos=(0, y, 0.95), verts=10)
        lib.cylinder(pearl, 0.06, 0.04, pos=(0, y, 1.03), bevel=0.012)

    # Lead pipe from the mouthpiece into the valves
    lib.tube(brass, [(0, 1.2, 0.74), (0, 0.8, 0.74), (0, 0.3, 0.72), (0, 0.17, 0.72)], 0.035)
    mouth = [(0.0, 0.0), (0.035, 0.0), (0.04, 0.1), (0.07, 0.17), (0.075, 0.19), (0.05, 0.19), (0.0, 0.16)]
    lib.lathe(silver, mouth, pos=(0, 1.18, 0.74), rot=(-90, 0, 0), segments=24)

    # Bell pipe running forward to the flared bell
    lib.tube(brass, [(0, -0.17, 0.5), (0, -0.35, 0.5), (0, -0.6, 0.5)], 0.04)
    bell = [(0.04, 0.0), (0.05, 0.25), (0.07, 0.45), (0.11, 0.58), (0.19, 0.68), (0.33, 0.75), (0.36, 0.77),
            (0.35, 0.785), (0.31, 0.765), (0.17, 0.69), (0.09, 0.57), (0.035, 0.25), (0.03, 0.0)]
    lib.lathe(brass, bell, pos=(0, -0.58, 0.5), rot=(90, 0, 0), segments=48, closed=True)

    # Main tuning slide: a U-bend looping back under the lead pipe
    lib.tube(brass, [(0, 0.17, 0.45), (0, 0.6, 0.45), (0, 0.85, 0.4), (0, 0.85, 0.22), (0, 0.6, 0.17),
                     (0, 0.17, 0.17), (0, -0.17, 0.2), (0, -0.25, 0.35), (0, -0.17, 0.42)], 0.035)
    # Small slides under the valves and a finger hook
    for y in (-0.17, 0.17):
        lib.tube(brass, [(0, y, 0.3), (0.05, y, 0.2), (0.12, y, 0.2), (0.12, y, 0.42)], 0.022)
    lib.tube(brass, [(0, 0.35, 0.74), (0.06, 0.38, 0.84), (0.0, 0.42, 0.88)], 0.012)
