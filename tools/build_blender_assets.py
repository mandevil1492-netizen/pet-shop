import bpy
import os
from math import radians


OUT_DIR = os.path.join(os.getcwd(), "assets", "models")


def reset_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in bpy.data.meshes:
        bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        bpy.data.materials.remove(block)


def mat(name, color):
    material = bpy.data.materials.new(name=name)
    material.use_nodes = True
    nodes = material.node_tree.nodes
    links = material.node_tree.links
    nodes.clear()

    bsdf = nodes.new(type="ShaderNodeBsdfPrincipled")
    bsdf.location = (0, 0)
    out = nodes.new(type="ShaderNodeOutputMaterial")
    out.location = (220, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.65
    return material


def export_obj(obj, filename):
    for other in bpy.context.scene.objects:
        other.select_set(False)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.gltf(
        filepath=os.path.join(OUT_DIR, filename),
        use_selection=True,
        export_format="GLB",
    )


def build_counter():
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.5))
    base = bpy.context.active_object
    base.scale = (1.7, 0.55, 0.5)
    base.data.materials.append(mat("counter_body", (0.96, 0.93, 0.88)))

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.05))
    top = bpy.context.active_object
    top.scale = (1.85, 0.62, 0.08)
    top.data.materials.append(mat("counter_top", (0.72, 0.54, 0.36)))

    bpy.ops.object.select_all(action="DESELECT")
    base.select_set(True)
    top.select_set(True)
    bpy.context.view_layer.objects.active = base
    bpy.ops.object.join()
    base.name = "Counter"
    return base


def build_exam_table():
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.75))
    top = bpy.context.active_object
    top.scale = (1.3, 0.7, 0.08)
    top.data.materials.append(mat("table_top", (0.83, 0.92, 0.97)))

    for x in (-1.1, 1.1):
        for y in (-0.5, 0.5):
            bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=1.3, location=(x * 0.5, y * 0.5, 0.35))
            leg = bpy.context.active_object
            leg.data.materials.append(mat("table_leg", (0.67, 0.74, 0.8)))

    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = top
    bpy.ops.object.join()
    top.name = "ExamTable"
    return top


def build_shelf():
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -0.2, 1.1))
    back = bpy.context.active_object
    back.scale = (0.7, 0.06, 1.1)
    back.data.materials.append(mat("shelf_main", (0.92, 0.95, 0.98)))

    levels = [0.35, 0.9, 1.45, 2.0]
    for z in levels:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, z))
        plank = bpy.context.active_object
        plank.scale = (0.7, 0.33, 0.05)
        plank.data.materials.append(mat("shelf_plank", (0.82, 0.88, 0.94)))

    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = back
    bpy.ops.object.join()
    back.name = "Shelf"
    return back


def build_medicine_cart():
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.6))
    body = bpy.context.active_object
    body.scale = (0.55, 0.38, 0.55)
    body.data.materials.append(mat("cart_body", (0.76, 0.86, 0.94)))

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.2))
    handle = bpy.context.active_object
    handle.scale = (0.58, 0.02, 0.16)
    handle.data.materials.append(mat("cart_handle", (0.61, 0.68, 0.75)))

    wheel_positions = [(-0.4, -0.25), (0.4, -0.25), (-0.4, 0.25), (0.4, 0.25)]
    for wx, wy in wheel_positions:
        bpy.ops.mesh.primitive_torus_add(
            major_radius=0.06,
            minor_radius=0.02,
            location=(wx * 0.55, wy * 0.38, 0.08),
            rotation=(radians(90), 0, 0),
        )
        wheel = bpy.context.active_object
        wheel.data.materials.append(mat("cart_wheel", (0.2, 0.2, 0.24)))

    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = body
    bpy.ops.object.join()
    body.name = "MedicineCart"
    return body


def build_plant():
    bpy.ops.mesh.primitive_cylinder_add(radius=0.2, depth=0.35, location=(0, 0, 0.17))
    pot = bpy.context.active_object
    pot.data.materials.append(mat("pot", (0.64, 0.42, 0.3)))

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.35, location=(0, 0, 0.65))
    leaves = bpy.context.active_object
    leaves.scale = (0.9, 0.9, 1.2)
    leaves.data.materials.append(mat("leaves", (0.44, 0.68, 0.42)))

    bpy.ops.object.select_all(action="DESELECT")
    pot.select_set(True)
    leaves.select_set(True)
    bpy.context.view_layer.objects.active = pot
    bpy.ops.object.join()
    pot.name = "Plant"
    return pot


def build_chair():
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.45))
    seat = bpy.context.active_object
    seat.scale = (0.38, 0.38, 0.08)
    seat.data.materials.append(mat("chair_seat", (0.22, 0.62, 0.76)))

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -0.28, 0.9))
    back = bpy.context.active_object
    back.scale = (0.38, 0.08, 0.35)
    back.data.materials.append(mat("chair_back", (0.2, 0.58, 0.72)))

    for x in (-0.28, 0.28):
        for y in (-0.28, 0.28):
            bpy.ops.mesh.primitive_cylinder_add(radius=0.03, depth=0.46, location=(x * 0.7, y * 0.7, 0.2))
            leg = bpy.context.active_object
            leg.data.materials.append(mat("chair_leg", (0.72, 0.76, 0.8)))

    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = seat
    bpy.ops.object.join()
    seat.name = "Chair"
    return seat


def build_monitor():
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.5))
    screen = bpy.context.active_object
    screen.scale = (0.45, 0.05, 0.28)
    screen.data.materials.append(mat("monitor_screen", (0.18, 0.2, 0.25)))

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -0.04, 0.48))
    panel = bpy.context.active_object
    panel.scale = (0.39, 0.01, 0.22)
    panel.data.materials.append(mat("monitor_panel", (0.32, 0.72, 0.82)))

    bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.25, location=(0, 0, 0.27))
    neck = bpy.context.active_object
    neck.data.materials.append(mat("monitor_neck", (0.62, 0.66, 0.72)))

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.05, 0.12))
    base = bpy.context.active_object
    base.scale = (0.2, 0.12, 0.02)
    base.data.materials.append(mat("monitor_base", (0.62, 0.66, 0.72)))

    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = screen
    bpy.ops.object.join()
    screen.name = "Monitor"
    return screen


def build_lamp():
    bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.55, location=(0, 0, 1.3))
    stick = bpy.context.active_object
    stick.data.materials.append(mat("lamp_stick", (0.82, 0.84, 0.88)))

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.2, location=(0, 0, 0.98))
    bulb = bpy.context.active_object
    bulb.scale = (1.0, 1.0, 0.85)
    bulb.data.materials.append(mat("lamp_bulb", (1.0, 0.95, 0.72)))

    bpy.ops.mesh.primitive_torus_add(
        major_radius=0.26,
        minor_radius=0.04,
        location=(0, 0, 0.96),
        rotation=(radians(90), 0, 0),
    )
    ring = bpy.context.active_object
    ring.data.materials.append(mat("lamp_ring", (0.88, 0.9, 0.93)))

    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = stick
    bpy.ops.object.join()
    stick.name = "Lamp"
    return stick


def build_pet_cage():
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.48))
    frame = bpy.context.active_object
    frame.scale = (0.7, 0.5, 0.45)
    frame.data.materials.append(mat("cage_frame", (0.7, 0.76, 0.84)))

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.48))
    cut = bpy.context.active_object
    cut.scale = (0.62, 0.42, 0.36)
    cut.display_type = "WIRE"

    mod = frame.modifiers.new("cage_hollow", "BOOLEAN")
    mod.operation = "DIFFERENCE"
    mod.object = cut
    bpy.context.view_layer.objects.active = frame
    bpy.ops.object.modifier_apply(modifier="cage_hollow")
    bpy.data.objects.remove(cut, do_unlink=True)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.52, 0.48))
    door = bpy.context.active_object
    door.scale = (0.26, 0.02, 0.23)
    door.data.materials.append(mat("cage_door", (0.88, 0.92, 0.97)))

    bpy.ops.object.select_all(action="DESELECT")
    frame.select_set(True)
    door.select_set(True)
    bpy.context.view_layer.objects.active = frame
    bpy.ops.object.join()
    frame.name = "PetCage"
    return frame


def build_vet_character():
    skin = mat("vet_skin", (0.96, 0.8, 0.68))
    cloth = mat("vet_cloth", (0.24, 0.54, 0.86))
    pants = mat("vet_pants", (0.16, 0.22, 0.34))
    hair = mat("vet_hair", (0.19, 0.14, 0.1))

    bpy.ops.mesh.primitive_cylinder_add(radius=0.24, depth=0.9, location=(0, 0, 0.9))
    torso = bpy.context.active_object
    torso.data.materials.append(cloth)

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(0, 0, 1.52))
    head = bpy.context.active_object
    head.data.materials.append(skin)

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.16, location=(0, -0.02, 1.6))
    cap = bpy.context.active_object
    cap.scale = (1.0, 1.0, 0.55)
    cap.data.materials.append(hair)

    for sx in (-1, 1):
        bpy.ops.mesh.primitive_cylinder_add(
            radius=0.07, depth=0.62, location=(sx * 0.22, 0, 0.34), rotation=(0, 0, radians(5 * sx))
        )
        leg = bpy.context.active_object
        leg.data.materials.append(pants)

        bpy.ops.mesh.primitive_cylinder_add(
            radius=0.055, depth=0.62, location=(sx * 0.34, 0, 1.0), rotation=(0, 0, radians(90))
        )
        arm = bpy.context.active_object
        arm.data.materials.append(skin)

    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = torso
    bpy.ops.object.join()
    torso.name = "VetCharacter"
    return torso


def build_pet_character():
    fur = mat("pet_fur", (0.88, 0.72, 0.48))
    inner = mat("pet_inner", (0.96, 0.88, 0.74))
    nose = mat("pet_nose", (0.2, 0.15, 0.15))

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(0, 0, 0.28))
    body = bpy.context.active_object
    body.scale = (1.2, 0.9, 0.8)
    body.data.materials.append(fur)

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.16, location=(0.2, 0, 0.36))
    head = bpy.context.active_object
    head.scale = (1.0, 0.95, 0.95)
    head.data.materials.append(fur)

    for y in (-0.08, 0.08):
        bpy.ops.mesh.primitive_cone_add(radius1=0.05, depth=0.12, location=(0.18, y, 0.52), rotation=(0, 0, radians(16)))
        ear = bpy.context.active_object
        ear.data.materials.append(inner)

    for x in (-0.1, 0.14):
        for y in (-0.07, 0.07):
            bpy.ops.mesh.primitive_cylinder_add(radius=0.03, depth=0.15, location=(x, y, 0.08))
            leg = bpy.context.active_object
            leg.data.materials.append(fur)

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.025, location=(0.33, 0, 0.34))
    sn = bpy.context.active_object
    sn.data.materials.append(nose)

    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = body
    bpy.ops.object.join()
    body.name = "PetCharacter"
    return body


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    builders = [
        (build_counter, "counter.glb"),
        (build_exam_table, "exam_table.glb"),
        (build_shelf, "shelf.glb"),
        (build_medicine_cart, "medicine_cart.glb"),
        (build_plant, "plant.glb"),
        (build_chair, "chair.glb"),
        (build_monitor, "monitor.glb"),
        (build_lamp, "lamp.glb"),
        (build_pet_cage, "pet_cage.glb"),
        (build_vet_character, "vet_character.glb"),
        (build_pet_character, "pet_character.glb"),
    ]

    for build_fn, out_name in builders:
        reset_scene()
        obj = build_fn()
        export_obj(obj, out_name)


if __name__ == "__main__":
    main()
