"""Retro game console with a wired controller in front (-Y). About 0.45 studs tall."""


def build(lib):
    Look = lib.Look
    shell = Look("Shell", (75, 75, 92), roughness=0.4)
    top = Look("ShellTop", (95, 95, 115), roughness=0.4)
    pad = Look("Controller", (40, 40, 50), roughness=0.4)
    dark = lib.DARK
    led = Look("Led", (80, 255, 120), "Neon", emission=3)
    btn = {
        "BtnRed": (240, 60, 60), "BtnGreen": (60, 200, 90), "BtnBlue": (60, 120, 240), "BtnYellow": (250, 210, 50),
    }
    cable = Look("Cable", (30, 30, 36), roughness=0.6)

    # Console: two-tone body with vents, cartridge slot, power button and light
    lib.box(shell, (1.4, 1.0, 0.24), pos=(0, 0.25, 0.12), bevel=0.06, bevel_segments=3)
    lib.box(top, (1.3, 0.9, 0.1), pos=(0, 0.25, 0.27), bevel=0.04, bevel_segments=3)
    lib.box(dark, (0.7, 0.14, 0.03), pos=(0, 0.32, 0.32), bevel=0.01)
    for k in range(6):
        lib.box(dark, (0.02, 0.4, 0.02), pos=(-0.55 + k * 0.05, 0.4, 0.32), bevel=0)
    lib.box(dark, (0.18, 0.1, 0.06), pos=(0.42, -0.08, 0.32), bevel=0.02)
    lib.box(led, (0.1, 0.02, 0.03), pos=(0.5, -0.255, 0.18), bevel=0.005)
    for x in (-0.3, -0.12):
        lib.box(dark, (0.12, 0.02, 0.06), pos=(x, -0.255, 0.12), bevel=0.01)

    # Controller: dog-bone shape with a D-pad and four colored buttons
    outline = [(-0.42, -0.14), (-0.3, -0.2), (-0.15, -0.12), (0.15, -0.12), (0.3, -0.2), (0.42, -0.14),
               (0.45, 0.04), (0.38, 0.17), (0.2, 0.14), (-0.2, 0.14), (-0.38, 0.17), (-0.45, 0.04)]
    lib.slab(pad, outline, 0.12, pos=(0, -0.62, 0.07), bevel=0.04)
    lib.box(dark, (0.16, 0.05, 0.03), pos=(-0.25, -0.6, 0.14), bevel=0.008)
    lib.box(dark, (0.05, 0.16, 0.03), pos=(-0.25, -0.6, 0.14), bevel=0.008)
    for (name, color), (dx, dy) in zip(btn.items(), ((0.25, -0.67), (0.32, -0.6), (0.25, -0.53), (0.18, -0.6))):
        lib.cylinder(Look(name, color, roughness=0.25), 0.03, 0.04, pos=(dx, dy, 0.14), verts=16, bevel=0.01)
    for x in (-0.05, 0.05):
        lib.box(dark, (0.07, 0.025, 0.02), pos=(x, -0.6, 0.135), rot=(0, 0, 30), bevel=0.005)

    # Cable from the controller to the console
    lib.tube(cable, [(0, -0.48, 0.09), (0.05, -0.38, 0.03), (-0.1, -0.3, 0.03), (-0.3, -0.27, 0.08),
                     (-0.3, -0.25, 0.1)], 0.015)
