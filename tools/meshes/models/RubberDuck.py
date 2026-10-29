"""Rubber duck, front (head) facing -Y. About 1.3 studs tall."""


def build(lib):
    Look = lib.Look
    yellow = Look("Yellow", (255, 214, 40), roughness=0.35)
    orange = Look("Beak", (255, 135, 30), roughness=0.35)
    eye = lib.DARK
    shine = lib.WHITE

    # Body: a squashed egg, with the tail flicking up at the back
    lib.sphere(yellow, 0.5, pos=(0, 0.05, 0.4), scale=(1.0, 1.25, 0.8))
    lib.sphere(yellow, 0.22, pos=(0, 0.6, 0.62), scale=(0.9, 1.0, 1.1), rot=(-30, 0, 0))
    # Wings on the sides
    for side in (-1, 1):
        lib.sphere(yellow, 0.24, pos=(side * 0.44, 0.12, 0.48), scale=(0.35, 1.0, 0.65), rot=(15, 0, 0))

    # Head, cheeks and beak
    lib.sphere(yellow, 0.34, pos=(0, -0.28, 1.0))
    lib.sphere(orange, 0.2, pos=(0, -0.62, 0.92), scale=(1.0, 1.0, 0.38))
    lib.sphere(orange, 0.16, pos=(0, -0.58, 0.86), scale=(0.85, 0.9, 0.3))

    # Eyes with a white sparkle
    for side in (-1, 1):
        lib.sphere(eye, 0.065, pos=(side * 0.15, -0.55, 1.1), segments=16, rings=10)
        lib.sphere(shine, 0.022, pos=(side * 0.15 + 0.02, -0.61, 1.13), segments=8, rings=6)
