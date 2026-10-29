"""Helpers for building game models in Blender with code.

Models are built Z-up with their front facing -Y (Blender's usual front).
Every piece is given a "look" (color + Roblox material). Pieces with the same
look are merged into one mesh, so a model ends up as a few MeshParts in Roblox,
named after their looks. The game re-applies the colors/materials by name.
"""

import math

import bpy  # must be imported before bmesh/mathutils
import bmesh
from mathutils import Euler, Vector, noise

_pieces = []  # (object, look)
_materials = {}


class Look:
    def __init__(self, name, color, material="SmoothPlastic", metallic=0.0, roughness=0.5,
                 emission=0.0, transparency=0.0, reflectance=0.0):
        self.name = name
        self.color = color  # (r, g, b) 0-255
        self.material = material  # Roblox material name
        self.metallic = metallic
        self.roughness = roughness
        self.emission = emission
        self.transparency = transparency
        self.reflectance = reflectance

    def to_dict(self):
        return {
            "Color": list(self.color),
            "Material": self.material,
            "Transparency": self.transparency,
            "Reflectance": self.reflectance,
        }


# Common looks
GOLD = Look("Gold", (255, 196, 54), "Metal", metallic=1.0, roughness=0.25, reflectance=0.2)
STEEL = Look("Steel", (190, 195, 205), "Metal", metallic=1.0, roughness=0.3)
DARK = Look("Dark", (40, 40, 48), "SmoothPlastic", roughness=0.4)
WHITE = Look("White", (245, 245, 245))


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    _pieces.clear()
    _materials.clear()


def _material(look):
    if look.name in _materials:
        return _materials[look.name]
    m = bpy.data.materials.new(look.name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    rgba = tuple((c / 255) ** 2.2 for c in look.color) + (1.0,)
    bsdf.inputs["Base Color"].default_value = rgba
    bsdf.inputs["Metallic"].default_value = look.metallic
    bsdf.inputs["Roughness"].default_value = look.roughness
    if look.emission:
        bsdf.inputs["Emission Color"].default_value = rgba
        bsdf.inputs["Emission Strength"].default_value = look.emission
    if look.transparency:
        bsdf.inputs["Alpha"].default_value = 1 - look.transparency
    _materials[look.name] = m
    return m


def _activate(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def finish(obj, look, smooth=True, bevel=0.0, bevel_segments=2, subsurf=0):
    """Applies optional bevel / smoothing, sets the look and registers the piece."""
    _activate(obj)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = bevel_segments
        mod.limit_method = "ANGLE"
        bpy.ops.object.modifier_apply(modifier=mod.name)
    if subsurf > 0:
        mod = obj.modifiers.new("Subsurf", "SUBSURF")
        mod.levels = subsurf
        mod.render_levels = subsurf
        bpy.ops.object.modifier_apply(modifier=mod.name)
    if smooth:
        bpy.ops.object.shade_smooth_by_angle(angle=math.radians(35))
    else:
        bpy.ops.object.shade_flat()
    obj.data.materials.clear()
    obj.data.materials.append(_material(look))
    _pieces.append((obj, look))
    return obj


def _place(obj, pos, rot):
    obj.location = Vector(pos)
    obj.rotation_euler = Euler([math.radians(a) for a in rot])
    _activate(obj)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return obj


# Primitives -----------------------------------------------------------------

def box(look, size, pos=(0, 0, 0), rot=(0, 0, 0), bevel=0.02, **kw):
    bpy.ops.mesh.primitive_cube_add(size=1)
    obj = bpy.context.active_object
    obj.scale = size
    _activate(obj)
    bpy.ops.object.transform_apply(scale=True)
    _place(obj, pos, rot)
    return finish(obj, look, bevel=bevel, smooth=kw.pop("smooth", True), **kw)


def cylinder(look, radius, depth, pos=(0, 0, 0), rot=(0, 0, 0), verts=32, bevel=0.01, **kw):
    """Cylinder standing along Z (use rot to lay it down)."""
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth)
    obj = _place(bpy.context.active_object, pos, rot)
    return finish(obj, look, bevel=bevel, **kw)


def sphere(look, radius, pos=(0, 0, 0), scale=(1, 1, 1), rot=(0, 0, 0), segments=32, rings=16, **kw):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, radius=radius)
    obj = bpy.context.active_object
    obj.scale = scale
    _place(obj, pos, rot)
    return finish(obj, look, **kw)


def gem(look, radius, pos=(0, 0, 0), rot=(0, 0, 0), facets=8, height=1.0):
    """Faceted gem: a cut stone with a flat top and pointed bottom."""
    bm = bmesh.new()
    top, girdle, tip = radius * 0.35 * height, 0.0, -radius * 0.9 * height
    rings = [(radius * 0.6, top), (radius, girdle)]
    verts = []
    for r, z in rings:
        ring = []
        for i in range(facets):
            a = 2 * math.pi * (i + 0.5 * (r != radius)) / facets
            ring.append(bm.verts.new((r * math.cos(a), r * math.sin(a), z)))
        verts.append(ring)
    bot = bm.verts.new((0, 0, tip))
    bm.faces.new(verts[0])
    for i in range(facets):
        j = (i + 1) % facets
        bm.faces.new((verts[0][i], verts[1][i], verts[1][j], verts[0][j]))
        bm.faces.new((verts[1][j], verts[1][i], bot))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    mesh = bpy.data.meshes.new("Gem")
    bm.to_mesh(mesh)
    obj = bpy.data.objects.new("Gem", mesh)
    bpy.context.collection.objects.link(obj)
    _place(obj, pos, rot)
    return finish(obj, look, smooth=False)


def torus(look, major, minor, pos=(0, 0, 0), rot=(0, 0, 0), major_seg=48, minor_seg=12, **kw):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor,
                                     major_segments=major_seg, minor_segments=minor_seg)
    obj = _place(bpy.context.active_object, pos, rot)
    return finish(obj, look, **kw)


def lathe(look, profile, pos=(0, 0, 0), rot=(0, 0, 0), segments=48, cap_bottom=True, cap_top=False,
          closed=False, **kw):
    """Spins a profile of (radius, z) points around the Z axis, like a pottery wheel."""
    bm = bmesh.new()
    rings = []
    for r, z in profile:
        ring = []
        for i in range(segments):
            a = 2 * math.pi * i / segments
            ring.append(bm.verts.new((r * math.cos(a), r * math.sin(a), z)))
        rings.append(ring)
    pairs = list(range(len(rings) - 1)) + ([len(rings) - 1] if closed else [])
    for k in pairs:
        nxt = (k + 1) % len(rings)
        for i in range(segments):
            j = (i + 1) % segments
            bm.faces.new((rings[k][i], rings[k][j], rings[nxt][j], rings[nxt][i]))
    if cap_bottom and not closed and profile[0][0] > 0:
        bm.faces.new(list(reversed(rings[0])))
    if cap_top and not closed and profile[-1][0] > 0:
        bm.faces.new(rings[-1])
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    mesh = bpy.data.meshes.new("Lathe")
    bm.to_mesh(mesh)
    obj = bpy.data.objects.new("Lathe", mesh)
    bpy.context.collection.objects.link(obj)
    _place(obj, pos, rot)
    return finish(obj, look, **kw)


def tube(look, points, radius, closed=False, resolution=8, bevel_res=4, **kw):
    """A round tube following a smooth path through 3D points (handles, arches...)."""
    curve = bpy.data.curves.new("Tube", "CURVE")
    curve.dimensions = "3D"
    curve.resolution_u = resolution
    curve.bevel_depth = radius
    curve.bevel_resolution = bevel_res
    curve.use_fill_caps = True
    spline = curve.splines.new("BEZIER")
    spline.bezier_points.add(len(points) - 1)
    for bp, p in zip(spline.bezier_points, points):
        bp.co = p
        bp.handle_left_type = bp.handle_right_type = "AUTO"
    spline.use_cyclic_u = closed
    obj = bpy.data.objects.new("Tube", curve)
    bpy.context.collection.objects.link(obj)
    _activate(obj)
    bpy.ops.object.convert(target="MESH")
    return finish(bpy.context.active_object, look, **kw)


def rod(look, start, end, radius, verts=12, **kw):
    """A straight thin cylinder from start to end (strings, bars...)."""
    a, b = Vector(start), Vector(end)
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=(b - a).length)
    obj = bpy.context.active_object
    obj.location = (a + b) / 2
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(b - a)
    _activate(obj)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return finish(obj, look, **kw)


def slab(look, outline, thickness, pos=(0, 0, 0), rot=(0, 0, 0), bevel=0.03, resolution=6, sharp=False, **kw):
    """A flat shape from a smooth 2D outline (x, y), with rounded edges, extruded along Z."""
    curve = bpy.data.curves.new("Slab", "CURVE")
    curve.dimensions = "2D"
    curve.fill_mode = "BOTH"
    curve.resolution_u = resolution
    curve.extrude = max(thickness / 2 - bevel, 0.001)
    curve.bevel_depth = bevel
    curve.bevel_resolution = 3
    spline = curve.splines.new("BEZIER")
    spline.bezier_points.add(len(outline) - 1)
    for bp, (x, y) in zip(spline.bezier_points, outline):
        bp.co = (x, y, 0)
        bp.handle_left_type = bp.handle_right_type = "VECTOR" if sharp else "AUTO"
    spline.use_cyclic_u = True
    obj = bpy.data.objects.new("Slab", curve)
    bpy.context.collection.objects.link(obj)
    _activate(obj)
    bpy.ops.object.convert(target="MESH")
    obj = bpy.context.active_object
    _place(obj, pos, rot)
    return finish(obj, look, **kw)


def blob(look, radius, pos=(0, 0, 0), scale=(1, 1, 1), seed=0.0, lumps=0.35, detail=0.08, subdivisions=3,
         **kw):
    """A lumpy ball (rocks, bushes, tree leaves): an ico-sphere pushed in and out with noise."""
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=radius)
    obj = bpy.context.active_object
    offset = Vector((seed, seed * 2.0, seed * 3.0))
    for v in obj.data.vertices:
        big = noise.noise(v.co * (2.2 / radius) + offset)
        small = noise.noise(v.co * (5.0 / radius) + offset * 1.7)
        v.co *= 1 + lumps * big + detail * small
        v.co = Vector((v.co.x * scale[0], v.co.y * scale[1], v.co.z * scale[2]))
    _place(obj, pos, (0, 0, 0))
    return finish(obj, look, **kw)


# Output ---------------------------------------------------------------------

def merge_by_look():
    """Joins pieces that share a look. Returns {look name: Look}."""
    groups = {}
    for obj, look in _pieces:
        groups.setdefault(look.name, (look, []))[1].append(obj)
    looks = {}
    for name, (look, objs) in groups.items():
        bpy.ops.object.select_all(action="DESELECT")
        for o in objs:
            o.select_set(True)
        bpy.context.view_layer.objects.active = objs[0]
        if len(objs) > 1:
            bpy.ops.object.join()
        merged = bpy.context.active_object
        merged.name = name
        merged.data.name = name
        looks[name] = look
    return looks


def triangle_counts():
    counts = {}
    for obj in bpy.context.scene.objects:
        if obj.type == "MESH":
            counts[obj.name] = sum(len(p.vertices) - 2 for p in obj.data.polygons)
    return counts


def bounds():
    lo = Vector((1e9, 1e9, 1e9))
    hi = Vector((-1e9, -1e9, -1e9))
    for obj in bpy.context.scene.objects:
        if obj.type == "MESH":
            for v in obj.data.vertices:
                co = obj.matrix_world @ v.co
                lo = Vector(map(min, lo, co))
                hi = Vector(map(max, hi, co))
    return lo, hi


def export_fbx(path):
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, apply_unit_scale=True,
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE",
                             add_leaf_bones=False, bake_anim=False)


def render_preview(path, size=900):
    lo, hi = bounds()
    center = (lo + hi) / 2
    extent = max((hi - lo).length, 0.01)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 64
    try:
        scene.cycles.use_denoising = True
    except Exception:
        pass
    scene.render.resolution_x = size
    scene.render.resolution_y = size
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "Standard"

    world = bpy.data.worlds.new("World")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = (0.55, 0.6, 0.68, 1)
    world.node_tree.nodes["Background"].inputs[1].default_value = 0.6
    scene.world = world

    bpy.ops.mesh.primitive_plane_add(size=extent * 20, location=(center.x, center.y, lo.z))
    floor = bpy.context.active_object
    floor.data.materials.append(_material(Look("Floor", (210, 212, 218), roughness=0.8)))

    bpy.ops.object.light_add(type="AREA", location=(center.x - extent, center.y - extent * 1.2, hi.z + extent))
    key = bpy.context.active_object
    key.data.energy = 40 * extent ** 2
    key.data.size = extent * 1.5
    key.rotation_euler = (math.radians(50), 0, math.radians(-40))
    bpy.ops.object.light_add(type="SUN", location=(0, 0, 10))
    sun = bpy.context.active_object
    sun.data.energy = 1.2
    sun.rotation_euler = (math.radians(40), math.radians(15), math.radians(30))

    cam_data = bpy.data.cameras.new("Cam")
    cam_data.lens = 50
    cam = bpy.data.objects.new("Cam", cam_data)
    bpy.context.collection.objects.link(cam)
    direction = Vector((0.55, -1.0, 0.45)).normalized()
    cam.location = center + direction * extent * 1.45
    cam.rotation_euler = (center - cam.location).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
