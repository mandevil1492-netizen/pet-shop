extends Node3D

enum CaseState {
	IDLE,
	TO_RECEPTION,
	CHECKIN,
	TO_EXAM,
	WAIT_DIAGNOSIS,
	TO_TREATMENT,
	WAIT_TREATMENT,
	DISCHARGE
}

const SAVE_PATH := "user://clinic_save.json"

@onready var day_label: Label = $CanvasLayer/HUD/TopBar/DayLabel
@onready var cash_label: Label = $CanvasLayer/HUD/TopBar/CashLabel
@onready var reputation_label: Label = $CanvasLayer/HUD/TopBar/ReputationLabel
@onready var queue_label: Label = $CanvasLayer/HUD/TopBar/QueueLabel
@onready var streak_label: Label = $CanvasLayer/HUD/TopBar/StreakLabel
@onready var satisfaction_label: Label = $CanvasLayer/HUD/TopBar/SatisfactionLabel

@onready var pet_label: Label = $CanvasLayer/HUD/WorkflowPanel/Margin/VBox/PetLabel
@onready var symptom_label: Label = $CanvasLayer/HUD/WorkflowPanel/Margin/VBox/SymptomLabel
@onready var treatment_label: Label = $CanvasLayer/HUD/WorkflowPanel/Margin/VBox/TreatmentLabel
@onready var severity_label: Label = $CanvasLayer/HUD/WorkflowPanel/Margin/VBox/SeverityLabel
@onready var status_label: Label = $CanvasLayer/HUD/WorkflowPanel/Margin/VBox/StatusLabel
@onready var reception_room_label: Label = $CanvasLayer/HUD/WorkflowPanel/Margin/VBox/ReceptionRoomLabel
@onready var exam_room_label: Label = $CanvasLayer/HUD/WorkflowPanel/Margin/VBox/ExamRoomLabel
@onready var treatment_room_label: Label = $CanvasLayer/HUD/WorkflowPanel/Margin/VBox/TreatmentRoomLabel

@onready var reception_upgrade_label: Label = $CanvasLayer/HUD/UpgradePanel/Margin/VBox/ReceptionLabel
@onready var exam_upgrade_label: Label = $CanvasLayer/HUD/UpgradePanel/Margin/VBox/ExamLabel
@onready var treatment_upgrade_label: Label = $CanvasLayer/HUD/UpgradePanel/Margin/VBox/TreatmentLabel
@onready var reception_upgrade_button: Button = $CanvasLayer/HUD/UpgradePanel/Margin/VBox/ReceptionButton
@onready var exam_upgrade_button: Button = $CanvasLayer/HUD/UpgradePanel/Margin/VBox/ExamButton
@onready var treatment_upgrade_button: Button = $CanvasLayer/HUD/UpgradePanel/Margin/VBox/TreatmentButton

@onready var diagnose_button: Button = $CanvasLayer/HUD/Actions/DiagnoseButton
@onready var treat_button: Button = $CanvasLayer/HUD/Actions/TreatButton
@onready var next_case_button: Button = $CanvasLayer/HUD/Actions/NextCaseButton
@onready var actions_container: HBoxContainer = $CanvasLayer/HUD/Actions

@onready var worker: Node3D = $Actors/Worker
@onready var patient: Node3D = $Actors/Patient
@onready var worker_visual_root: Node3D = $Actors/Worker/VisualRoot
@onready var patient_visual_root: Node3D = $Actors/Patient/VisualRoot
@onready var entrance_point: Marker3D = $Clinic/Stations/EntrancePoint
@onready var reception_point: Marker3D = $Clinic/Stations/ReceptionPoint
@onready var exam_point: Marker3D = $Clinic/Stations/ExamPoint
@onready var treatment_point: Marker3D = $Clinic/Stations/TreatmentPoint
@onready var exit_point: Marker3D = $Clinic/Stations/ExitPoint

@onready var counter_anchor: Marker3D = $Clinic/Props/CounterAnchor
@onready var exam_table_anchor: Marker3D = $Clinic/Props/ExamTableAnchor
@onready var shelf_anchor: Marker3D = $Clinic/Props/ShelfAnchor
@onready var cart_anchor: Marker3D = $Clinic/Props/CartAnchor
@onready var plant_anchor: Marker3D = $Clinic/Props/PlantAnchor
@onready var props_root: Node3D = $Clinic/Props
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var clinic_root: Node3D = $Clinic
@onready var sun_light: DirectionalLight3D = $DirectionalLight3D
@onready var main_camera: Camera3D = $Camera3D
@onready var reception_light: OmniLight3D = $ReceptionLight
@onready var exam_light: OmniLight3D = $ExamLight
@onready var treatment_light: OmniLight3D = $TreatmentLight
@onready var floor_mesh: MeshInstance3D = $Clinic/Floor
@onready var back_wall_mesh: MeshInstance3D = $Clinic/BackWall
@onready var left_wall_mesh: MeshInstance3D = $Clinic/LeftWall
@onready var right_wall_mesh: MeshInstance3D = $Clinic/RightWall

var day: int = 1
var cash: int = 1800
var reputation: int = 1
var queue_size: int = 4
var day_goal_cases: int = 4
var day_cases_done: int = 0
var total_cases_served: int = 0

var streak: int = 0
var satisfaction: int = 75
var clinic_score: int = 0
var total_earnings: int = 0
var failed_cases: int = 0

var reception_level: int = 1
var exam_level: int = 1
var treatment_level: int = 1

var case_state: CaseState = CaseState.IDLE
var worker_target: Vector3 = Vector3.ZERO
var patient_target: Vector3 = Vector3.ZERO
var interaction_timer: float = 0.0
var walk_cycle: float = 0.0

var case_elapsed: float = 0.0
var case_deadline: float = 30.0
var current_case: Dictionary = {}

var game_won: bool = false
var game_lost: bool = false
var day_night_time: float = 0.23
var integrity_check_timer: float = 0.0

var exterior_window_meshes: Array[MeshInstance3D] = []
var exterior_street_lights: Array[OmniLight3D] = []
var exterior_cars: Array[Dictionary] = []
var exterior_walkers: Array[Dictionary] = []
var billboard_screen_mat: StandardMaterial3D
var asphalt_material: ShaderMaterial
var lane_line_material: StandardMaterial3D
var concrete_material: ShaderMaterial
var path_material: ShaderMaterial
var grass_material: ShaderMaterial

var objective_label: Label
var help_label: Label
var emergency_button: Button
var achievement_label: Label
var unlocked: Dictionary = {
	"first_case": false,
	"streak_5": false,
	"rich_5000": false,
	"rep_10": false
}

var pets: Array[String] = ["Kedi", "Kopek", "Tavsan", "Kus", "Hamster", "Papagan"]
var symptoms: Array[String] = ["Istahsizlik", "Aksirma", "Topallama", "Kasinti", "Yorgunluk", "Sulu Goz", "Ates", "Kulak Enfeksiyonu"]
var correct_treatments: Dictionary = {
	"Istahsizlik": "Beslenme Programi",
	"Aksirma": "Enfeksiyon Ilaci",
	"Topallama": "Bandaj ve Dinlenme",
	"Kasinti": "Alerji Ilaci",
	"Yorgunluk": "Vitamin Destegi",
	"Sulu Goz": "Temizleme ve Damla",
	"Ates": "Acil Serum",
	"Kulak Enfeksiyonu": "Kulak Ilaci"
}

const BASE_WORKER_SPEED: float = 3.2
const BASE_PATIENT_SPEED: float = 2.6
const ARRIVE_EPS: float = 0.18

func _ready() -> void:
	randomize()
	_setup_runtime_ui()
	_enhance_visual_quality()
	_build_exterior_world()
	_spawn_characters()
	_spawn_props()
	_setup_clinic_positions()

	diagnose_button.pressed.connect(_on_diagnose_pressed)
	treat_button.pressed.connect(_on_treat_pressed)
	next_case_button.pressed.connect(_on_next_case_pressed)
	reception_upgrade_button.pressed.connect(_on_upgrade_reception)
	exam_upgrade_button.pressed.connect(_on_upgrade_exam)
	treatment_upgrade_button.pressed.connect(_on_upgrade_treatment)
	emergency_button.pressed.connect(_on_emergency_protocol)

	if AppState.consume_new_game_request():
		AppState.delete_save()
		_reset_progress_defaults()
		_start_new_day(true)
	elif not _load_game(false):
		_start_new_day(true)

	status_label.text = "Durum: Klinik hazir. Yeni hasta cagir."
	_refresh_ui()

	if OS.has_environment("CAPTURE_PREVIEW"):
		call_deferred("_capture_preview")

func _build_exterior_world() -> void:
	if has_node("Exterior"):
		get_node("Exterior").queue_free()

	exterior_window_meshes.clear()
	exterior_street_lights.clear()
	exterior_cars.clear()
	exterior_walkers.clear()
	billboard_screen_mat = null

	var exterior := Node3D.new()
	exterior.name = "Exterior"
	add_child(exterior)
	move_child(exterior, 0)

	var city_ground := _add_box(exterior, Vector3(120, 0.2, 120), Vector3(0, -0.11, 0), Color(0.34, 0.44, 0.34), 0.97, 0.0)
	city_ground.name = "CityGround"
	_add_box(exterior, Vector3(40, 0.21, 30), Vector3(0, -0.105, 0), Color(0.58, 0.63, 0.61), 0.93, 0.0)

	_build_road_network(exterior)
	_build_sidewalks_and_paths(exterior)
	_build_houses(exterior)
	_build_trees(exterior)
	_build_billboard(exterior)
	_build_street_lights(exterior)
	_build_ambient_traffic(exterior)
	_build_ambient_walkers(exterior)
	_apply_exterior_materials()
	_add_exterior_reflection_probe(exterior)

func _build_road_network(parent: Node3D) -> void:
	var road_col := Color(0.16, 0.17, 0.18)
	var road_a := _add_box(parent, Vector3(110, 0.06, 8), Vector3(0, -0.02, 16), road_col, 0.96, 0.02)
	var road_b := _add_box(parent, Vector3(110, 0.06, 8), Vector3(0, -0.02, -16), road_col, 0.96, 0.02)
	var road_c := _add_box(parent, Vector3(8, 0.06, 110), Vector3(24, -0.02, 0), road_col, 0.96, 0.02)
	var road_d := _add_box(parent, Vector3(8, 0.06, 110), Vector3(-24, -0.02, 0), road_col, 0.96, 0.02)
	road_a.name = "RoadMainA"
	road_b.name = "RoadMainB"
	road_c.name = "RoadCrossA"
	road_d.name = "RoadCrossB"

	var line_col := Color(0.94, 0.91, 0.55)
	for x in range(-46, 47, 8):
		var line_a := _add_box(parent, Vector3(3.2, 0.02, 0.26), Vector3(float(x), 0.02, 16), line_col, 0.4, 0.0)
		var line_b := _add_box(parent, Vector3(3.2, 0.02, 0.26), Vector3(float(x), 0.02, -16), line_col, 0.4, 0.0)
		line_a.name = "LaneLineX"
		line_b.name = "LaneLineX"
	for z in range(-46, 47, 8):
		var line_c := _add_box(parent, Vector3(0.26, 0.02, 3.2), Vector3(24, 0.02, float(z)), line_col, 0.4, 0.0)
		var line_d := _add_box(parent, Vector3(0.26, 0.02, 3.2), Vector3(-24, 0.02, float(z)), line_col, 0.4, 0.0)
		line_c.name = "LaneLineZ"
		line_d.name = "LaneLineZ"

func _build_sidewalks_and_paths(parent: Node3D) -> void:
	var sidewalk_col := Color(0.76, 0.76, 0.74)
	var sw_a := _add_box(parent, Vector3(54, 0.08, 3.4), Vector3(0, -0.01, 10.4), sidewalk_col, 0.82, 0.0)
	var sw_b := _add_box(parent, Vector3(54, 0.08, 3.4), Vector3(0, -0.01, -10.4), sidewalk_col, 0.82, 0.0)
	var sw_c := _add_box(parent, Vector3(3.4, 0.08, 44), Vector3(10.7, -0.01, 0), sidewalk_col, 0.82, 0.0)
	var sw_d := _add_box(parent, Vector3(3.4, 0.08, 44), Vector3(-10.7, -0.01, 0), sidewalk_col, 0.82, 0.0)
	sw_a.name = "Sidewalk"
	sw_b.name = "Sidewalk"
	sw_c.name = "Sidewalk"
	sw_d.name = "Sidewalk"

	var path_col := Color(0.67, 0.57, 0.43)
	var path_a := _add_box(parent, Vector3(28, 0.05, 2.2), Vector3(0, -0.025, 31), path_col, 0.9, 0.0)
	var path_b := _add_box(parent, Vector3(2.2, 0.05, 24), Vector3(-35, -0.025, 0), path_col, 0.9, 0.0)
	var path_c := _add_box(parent, Vector3(2.2, 0.05, 24), Vector3(35, -0.025, 0), path_col, 0.9, 0.0)
	path_a.name = "WalkPath"
	path_b.name = "WalkPath"
	path_c.name = "WalkPath"

func _build_houses(parent: Node3D) -> void:
	var house_positions := [
		Vector3(-44, 0, 28), Vector3(-30, 0, 28), Vector3(-16, 0, 28), Vector3(-2, 0, 28),
		Vector3(12, 0, 28), Vector3(26, 0, 28), Vector3(40, 0, 28),
		Vector3(-44, 0, -28), Vector3(-30, 0, -28), Vector3(-16, 0, -28), Vector3(-2, 0, -28),
		Vector3(12, 0, -28), Vector3(26, 0, -28), Vector3(40, 0, -28)
	]
	var palette := [
		Color(0.93, 0.84, 0.76),
		Color(0.82, 0.89, 0.8),
		Color(0.8, 0.84, 0.92),
		Color(0.92, 0.81, 0.84)
	]
	var roof_palette := [
		Color(0.41, 0.23, 0.2),
		Color(0.34, 0.28, 0.3),
		Color(0.36, 0.2, 0.18)
	]

	for i in house_positions.size():
		var h := Node3D.new()
		parent.add_child(h)
		h.position = house_positions[i]
		var body_col: Color = palette[i % palette.size()]
		var roof_col: Color = roof_palette[i % roof_palette.size()]
		var body := _add_box(h, Vector3(9.2, 4.4, 7.2), Vector3(0, 2.2, 0), body_col, 0.78, 0.0)
		body.name = "HouseBody"

		var roof := MeshInstance3D.new()
		var roof_mesh := PrismMesh.new()
		roof_mesh.size = Vector3(10.0, 2.8, 8.0)
		roof.mesh = roof_mesh
		roof.position = Vector3(0, 5.2, 0)
		var roof_mat := StandardMaterial3D.new()
		roof_mat.albedo_color = roof_col
		roof_mat.roughness = 0.87
		roof.material_override = roof_mat
		h.add_child(roof)

		_add_box(h, Vector3(1.2, 2.0, 0.18), Vector3(0, 1.0, 3.62), Color(0.38, 0.25, 0.16), 0.8, 0.0)
		var w1 := _add_box(h, Vector3(1.5, 1.1, 0.18), Vector3(-2.2, 2.2, 3.62), Color(0.75, 0.86, 0.95), 0.22, 0.0)
		var w2 := _add_box(h, Vector3(1.5, 1.1, 0.18), Vector3(2.2, 2.2, 3.62), Color(0.75, 0.86, 0.95), 0.22, 0.0)
		exterior_window_meshes.append(w1)
		exterior_window_meshes.append(w2)

func _build_trees(parent: Node3D) -> void:
	var tree_positions := [
		Vector3(-48, 0, 14), Vector3(-42, 0, 18), Vector3(-36, 0, 12),
		Vector3(48, 0, 14), Vector3(42, 0, 18), Vector3(36, 0, 12),
		Vector3(-48, 0, -14), Vector3(-42, 0, -18), Vector3(-36, 0, -12),
		Vector3(48, 0, -14), Vector3(42, 0, -18), Vector3(36, 0, -12),
		Vector3(-12, 0, 38), Vector3(0, 0, 38), Vector3(12, 0, 38),
		Vector3(-12, 0, -38), Vector3(0, 0, -38), Vector3(12, 0, -38)
	]
	var leaves := [Color(0.24, 0.45, 0.24), Color(0.31, 0.52, 0.29), Color(0.38, 0.58, 0.31)]

	for i in tree_positions.size():
		var t := Node3D.new()
		parent.add_child(t)
		t.position = tree_positions[i]

		var trunk := MeshInstance3D.new()
		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = 0.35
		trunk_mesh.bottom_radius = 0.42
		trunk_mesh.height = 2.8
		trunk.mesh = trunk_mesh
		trunk.position = Vector3(0, 1.4, 0)
		var trunk_mat := StandardMaterial3D.new()
		trunk_mat.albedo_color = Color(0.35, 0.23, 0.13)
		trunk_mat.roughness = 0.9
		trunk.material_override = trunk_mat
		t.add_child(trunk)

		var canopy := MeshInstance3D.new()
		var cap_mesh := SphereMesh.new()
		cap_mesh.radius = 1.6 + float(i % 3) * 0.18
		cap_mesh.height = cap_mesh.radius * 2.0
		canopy.mesh = cap_mesh
		canopy.position = Vector3(0, 3.6, 0)
		var cap_mat := StandardMaterial3D.new()
		cap_mat.albedo_color = leaves[i % leaves.size()]
		cap_mat.roughness = 0.88
		canopy.material_override = cap_mat
		t.add_child(canopy)

func _build_billboard(parent: Node3D) -> void:
	var billboard := Node3D.new()
	billboard.name = "Billboard"
	billboard.position = Vector3(0, 0, 45)
	parent.add_child(billboard)

	var pole_mat := StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.24, 0.26, 0.3)
	pole_mat.roughness = 0.55
	for x in [-4.5, 4.5]:
		var pole := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.22
		mesh.bottom_radius = 0.24
		mesh.height = 8.5
		pole.mesh = mesh
		pole.position = Vector3(x, 4.2, 0)
		pole.material_override = pole_mat
		billboard.add_child(pole)

	_add_box(billboard, Vector3(13.5, 5.6, 0.4), Vector3(0, 7.3, 0), Color(0.95, 0.96, 0.98), 0.42, 0.0)
	var display := _add_box(billboard, Vector3(12.3, 4.6, 0.22), Vector3(0, 7.3, 0.21), Color(0.14, 0.46, 0.78), 0.36, 0.0)
	if display.material_override is StandardMaterial3D:
		billboard_screen_mat = display.material_override as StandardMaterial3D

	var label := Label3D.new()
	label.text = "PATI PROTOKOLU\n24/7 ACIK VETERINER"
	label.font_size = 80
	label.position = Vector3(-3.7, 8.0, 0.45)
	label.modulate = Color(0.96, 0.98, 1.0)
	billboard.add_child(label)

func _build_street_lights(parent: Node3D) -> void:
	var positions := [
		Vector3(-18, 0, 16), Vector3(0, 0, 16), Vector3(18, 0, 16),
		Vector3(-18, 0, -16), Vector3(0, 0, -16), Vector3(18, 0, -16)
	]
	for p in positions:
		var lamp := Node3D.new()
		parent.add_child(lamp)
		lamp.position = p

		var pole := MeshInstance3D.new()
		var pole_mesh := CylinderMesh.new()
		pole_mesh.top_radius = 0.1
		pole_mesh.bottom_radius = 0.13
		pole_mesh.height = 5.2
		pole.mesh = pole_mesh
		pole.position = Vector3(0, 2.6, 0)
		var pole_mat := StandardMaterial3D.new()
		pole_mat.albedo_color = Color(0.32, 0.34, 0.36)
		pole_mat.roughness = 0.62
		pole.material_override = pole_mat
		lamp.add_child(pole)

		var head := MeshInstance3D.new()
		var head_mesh := SphereMesh.new()
		head_mesh.radius = 0.24
		head_mesh.height = 0.48
		head.mesh = head_mesh
		head.position = Vector3(0, 5.25, 0)
		var head_mat := StandardMaterial3D.new()
		head_mat.albedo_color = Color(0.98, 0.92, 0.74)
		head_mat.emission_enabled = true
		head_mat.emission = Color(1.0, 0.86, 0.6)
		head_mat.emission_energy_multiplier = 1.4
		head.material_override = head_mat
		lamp.add_child(head)

		var light := OmniLight3D.new()
		light.position = Vector3(0, 5.3, 0)
		light.light_energy = 0.8
		light.light_color = Color(1.0, 0.89, 0.7)
		light.omni_range = 9.5
		light.shadow_enabled = true
		light.light_size = 0.25
		lamp.add_child(light)
		exterior_street_lights.append(light)

func _build_ambient_traffic(parent: Node3D) -> void:
	var car_colors := [
		Color(0.82, 0.2, 0.18),
		Color(0.16, 0.48, 0.72),
		Color(0.76, 0.74, 0.72),
		Color(0.14, 0.19, 0.24),
		Color(0.7, 0.55, 0.18)
	]

	for i in range(7):
		var z_lane := 16.0 if i % 2 == 0 else -16.0
		var dir := 1.0 if i % 2 == 0 else -1.0
		var start_x := -54.0 + float(i) * 16.0
		var car := _create_car(parent, car_colors[i % car_colors.size()])
		car.position = Vector3(start_x, 0.04, z_lane + randf_range(-0.5, 0.5))
		car.rotation_degrees.y = -90.0 if dir > 0.0 else 90.0
		exterior_cars.append({
			"node": car,
			"speed": randf_range(5.0, 10.5),
			"dir": dir,
			"axis": "x",
			"min_v": -58.0,
			"max_v": 58.0
		})

	for i in range(4):
		var x_lane := 24.0 if i % 2 == 0 else -24.0
		var dir := 1.0 if i % 2 == 0 else -1.0
		var start_z := -52.0 + float(i) * 26.0
		var car := _create_car(parent, car_colors[(i + 2) % car_colors.size()])
		car.position = Vector3(x_lane + randf_range(-0.5, 0.5), 0.04, start_z)
		car.rotation_degrees.y = 0.0 if dir > 0.0 else 180.0
		exterior_cars.append({
			"node": car,
			"speed": randf_range(4.6, 9.2),
			"dir": dir,
			"axis": "z",
			"min_v": -58.0,
			"max_v": 58.0
		})

func _create_car(parent: Node3D, body_color: Color) -> Node3D:
	var car := Node3D.new()
	parent.add_child(car)

	_add_box(car, Vector3(2.8, 0.55, 1.4), Vector3(0, 0.32, 0), body_color, 0.35, 0.35)
	_add_box(car, Vector3(1.45, 0.45, 1.25), Vector3(-0.15, 0.72, 0), body_color.lightened(0.05), 0.3, 0.32)
	_add_box(car, Vector3(0.95, 0.22, 1.28), Vector3(-0.22, 0.71, 0), Color(0.63, 0.82, 0.94), 0.06, 0.02)
	_add_box(car, Vector3(0.3, 0.12, 1.18), Vector3(1.38, 0.33, 0), Color(1.0, 0.93, 0.75), 0.2, 0.0)
	_add_box(car, Vector3(0.3, 0.12, 1.18), Vector3(-1.38, 0.33, 0), Color(0.85, 0.2, 0.2), 0.2, 0.0)

	var wheel_col := Color(0.07, 0.07, 0.08)
	for wx in [-1.0, 1.0]:
		for wz in [-0.56, 0.56]:
			var wheel := MeshInstance3D.new()
			var tor := TorusMesh.new()
			tor.inner_radius = 0.08
			tor.outer_radius = 0.19
			wheel.mesh = tor
			wheel.position = Vector3(wx, 0.12, wz)
			wheel.rotation_degrees = Vector3(90, 0, 0)
			var wmat := StandardMaterial3D.new()
			wmat.albedo_color = wheel_col
			wmat.roughness = 0.84
			wheel.material_override = wmat
			car.add_child(wheel)

	return car

func _build_ambient_walkers(parent: Node3D) -> void:
	var walk_colors := [Color(0.26, 0.48, 0.8), Color(0.78, 0.43, 0.23), Color(0.34, 0.66, 0.38), Color(0.64, 0.42, 0.72)]
	for i in range(10):
		var axis := "x" if i % 2 == 0 else "z"
		var walker := _create_walker(parent, walk_colors[i % walk_colors.size()])
		var dir := 1.0 if i % 3 != 0 else -1.0
		if axis == "x":
			walker.position = Vector3(randf_range(-45, 45), 0.0, 10.7 if i % 4 < 2 else -10.7)
			walker.rotation_degrees.y = -90.0 if dir > 0.0 else 90.0
		else:
			walker.position = Vector3(10.7 if i % 4 < 2 else -10.7, 0.0, randf_range(-40, 40))
			walker.rotation_degrees.y = 0.0 if dir > 0.0 else 180.0
		exterior_walkers.append({
			"node": walker,
			"speed": randf_range(1.2, 2.2),
			"dir": dir,
			"axis": axis,
			"min_v": -50.0,
			"max_v": 50.0,
			"phase": randf() * TAU
		})

func _create_walker(parent: Node3D, shirt_col: Color) -> Node3D:
	var w := Node3D.new()
	parent.add_child(w)
	_add_box(w, Vector3(0.38, 0.72, 0.24), Vector3(0, 1.22, 0), shirt_col, 0.75, 0.0)
	_add_box(w, Vector3(0.26, 0.26, 0.24), Vector3(0, 1.74, 0), Color(0.94, 0.78, 0.66), 0.68, 0.0)
	_add_box(w, Vector3(0.11, 0.45, 0.11), Vector3(-0.09, 0.72, 0), Color(0.12, 0.15, 0.2), 0.8, 0.0)
	_add_box(w, Vector3(0.11, 0.45, 0.11), Vector3(0.09, 0.72, 0), Color(0.12, 0.15, 0.2), 0.8, 0.0)
	return w

func _add_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rough: float, metal: float) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	m.mesh = box
	m.position = pos
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	m.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	mat.metallic = metal
	m.material_override = mat
	parent.add_child(m)
	return m

func _prepare_surface_material_library() -> void:
	if asphalt_material and concrete_material and path_material and grass_material and lane_line_material:
		return

	var asphalt_shader := Shader.new()
	asphalt_shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 base_col : source_color = vec3(0.14, 0.15, 0.16);
uniform float wetness = 0.2;
uniform float scale = 5.8;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

void fragment() {
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 uv = wp.xz / scale;
	float n = hash21(floor(uv * 36.0));
	float grain = (n - 0.5) * 0.12;
	float crack = smoothstep(0.72, 0.95, abs(sin(uv.x * 18.0) * cos(uv.y * 15.0)));
	ALBEDO = base_col + vec3(grain - crack * 0.04);
	ROUGHNESS = mix(0.92, 0.52, wetness) + crack * 0.05;
	METALLIC = 0.02;
	SPECULAR = 0.42;
}
"""
	asphalt_material = ShaderMaterial.new()
	asphalt_material.shader = asphalt_shader

	lane_line_material = StandardMaterial3D.new()
	lane_line_material.albedo_color = Color(0.93, 0.88, 0.58)
	lane_line_material.roughness = 0.38
	lane_line_material.metallic = 0.0

	var concrete_shader := Shader.new()
	concrete_shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 base_col : source_color = vec3(0.73, 0.73, 0.72);
uniform float scale = 4.5;

float hash21(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 uv = wp.xz / scale;
	float n = hash21(floor(uv * 24.0));
	float p = hash21(floor(uv * 9.0));
	float dirt = smoothstep(0.65, 1.0, p) * 0.08;
	ALBEDO = base_col + vec3((n - 0.5) * 0.08 - dirt);
	ROUGHNESS = 0.84;
	METALLIC = 0.0;
	SPECULAR = 0.36;
}
"""
	concrete_material = ShaderMaterial.new()
	concrete_material.shader = concrete_shader

	var path_shader := Shader.new()
	path_shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 soil_a : source_color = vec3(0.5, 0.41, 0.31);
uniform vec3 soil_b : source_color = vec3(0.43, 0.34, 0.26);
uniform float scale = 3.8;

void fragment() {
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float pattern = sin(wp.x * scale) * cos(wp.z * scale * 0.8);
	float blend = smoothstep(-0.9, 0.9, pattern);
	ALBEDO = mix(soil_a, soil_b, blend);
	ROUGHNESS = 0.9;
	METALLIC = 0.0;
	SPECULAR = 0.24;
}
"""
	path_material = ShaderMaterial.new()
	path_material.shader = path_shader

	var grass_shader := Shader.new()
	grass_shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 grass_a : source_color = vec3(0.26, 0.39, 0.24);
uniform vec3 grass_b : source_color = vec3(0.19, 0.31, 0.18);
uniform float scale = 2.1;

void fragment() {
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float variation = sin(wp.x * scale) * sin(wp.z * scale * 0.9);
	float mask = smoothstep(-0.75, 0.75, variation);
	ALBEDO = mix(grass_a, grass_b, mask);
	ROUGHNESS = 0.96;
	METALLIC = 0.0;
	SPECULAR = 0.18;
}
"""
	grass_material = ShaderMaterial.new()
	grass_material.shader = grass_shader

func _apply_exterior_materials() -> void:
	if not has_node("Exterior"):
		return
	if not asphalt_material:
		_prepare_surface_material_library()

	var exterior := get_node("Exterior")
	for child in exterior.get_children():
		if child is MeshInstance3D:
			var mesh := child as MeshInstance3D
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
			if mesh.name.begins_with("Road"):
				mesh.material_override = asphalt_material
			elif mesh.name.begins_with("LaneLine"):
				mesh.material_override = lane_line_material
			elif mesh.name == "Sidewalk":
				mesh.material_override = concrete_material
			elif mesh.name == "WalkPath":
				mesh.material_override = path_material
			elif mesh.name == "CityGround":
				mesh.material_override = grass_material

func _capture_preview() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	if img:
		var out_path := ProjectSettings.globalize_path("user://preview.png")
		img.save_png(out_path)
	get_tree().quit()

func _enhance_visual_quality() -> void:
	_prepare_surface_material_library()
	var env: Environment = world_environment.environment
	if env:
		var sky_mat := PhysicalSkyMaterial.new()
		sky_mat.rayleigh_coefficient = 2.2
		sky_mat.mie_coefficient = 0.012
		sky_mat.mie_eccentricity = 0.82
		sky_mat.turbidity = 2.1
		sky_mat.sun_disk_scale = 1.2
		var sky := Sky.new()
		sky.sky_material = sky_mat
		env.background_mode = Environment.BG_SKY
		env.sky = sky
		env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		env.tonemap_exposure = 1.08
		env.tonemap_white = 1.2
		env.glow_enabled = true
		env.glow_bloom = 0.08
		env.glow_intensity = 0.62
		env.ssao_enabled = true
		env.ssao_radius = 2.2
		env.ssao_intensity = 1.35
		env.set("ssil_enabled", true)
		env.set("ssil_radius", 4.1)
		env.set("ssr_enabled", true)
		env.set("ssr_fade_in", 0.12)
		env.set("ssr_fade_out", 1.9)
		env.set("sdfgi_enabled", true)
		env.set("sdfgi_bounce_feedback", 0.42)
		env.set("sdfgi_energy", 1.18)
		env.set("adjustment_enabled", true)
		env.set("adjustment_contrast", 1.08)
		env.set("adjustment_saturation", 1.05)
		env.set("fog_enabled", true)
		env.set("fog_density", 0.006)
		env.set("fog_sky_affect", 0.24)
		env.set("volumetric_fog_enabled", true)
		env.set("volumetric_fog_density", 0.018)

	sun_light.light_energy = 1.65
	sun_light.light_color = Color(1.0, 0.96, 0.9)
	sun_light.shadow_enabled = true
	sun_light.shadow_blur = 1.15
	sun_light.set("directional_shadow_mode", DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
	sun_light.set("directional_shadow_max_distance", 120.0)
	sun_light.set("directional_shadow_fade_start", 0.85)
	sun_light.light_angular_distance = 0.45

	main_camera.set("near", 0.03)
	main_camera.set("far", 220.0)

	reception_light.shadow_enabled = true
	reception_light.light_energy = 1.45
	reception_light.light_size = 0.45
	exam_light.shadow_enabled = true
	exam_light.light_energy = 1.52
	exam_light.light_size = 0.42
	treatment_light.shadow_enabled = true
	treatment_light.light_energy = 1.48
	treatment_light.light_size = 0.43

	_apply_materials()
	_add_reflection_probe()
	_add_post_fx_overlay()

func _apply_materials() -> void:
	var floor_shader: Shader = Shader.new()
	floor_shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 c1 : source_color = vec3(0.88, 0.9, 0.92);
uniform vec3 c2 : source_color = vec3(0.80, 0.84, 0.88);
uniform float rough = 0.55;
uniform float tile = 1.8;

void fragment() {
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float nx = floor(wp.x * tile);
	float nz = floor(wp.z * tile);
	float checker = mod(nx + nz, 2.0);
	float grain = sin(wp.x * 18.0) * cos(wp.z * 15.0) * 0.03;
	ALBEDO = mix(c1, c2, checker) + vec3(grain);
	ROUGHNESS = rough;
	METALLIC = 0.06;
}
"""

	var floor_mat: ShaderMaterial = ShaderMaterial.new()
	floor_mat.shader = floor_shader
	floor_mesh.material_override = floor_mat

	var wall_shader: Shader = Shader.new()
	wall_shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 base_col : source_color = vec3(0.82, 0.88, 0.94);
uniform float rough = 0.72;

void fragment() {
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float vertical = fract(wp.y * 0.75) * 0.05;
	float subtle = sin(wp.x * 5.0 + wp.z * 3.0) * 0.015;
	ALBEDO = base_col + vec3(vertical + subtle);
	ROUGHNESS = rough;
	METALLIC = 0.02;
}
"""

	var wall_mat: ShaderMaterial = ShaderMaterial.new()
	wall_mat.shader = wall_shader
	back_wall_mesh.material_override = wall_mat
	left_wall_mesh.material_override = wall_mat
	right_wall_mesh.material_override = wall_mat

func _add_reflection_probe() -> void:
	if $Clinic.has_node("RuntimeReflectionProbe"):
		return
	var probe: ReflectionProbe = ReflectionProbe.new()
	probe.name = "RuntimeReflectionProbe"
	probe.position = Vector3(0, 2.2, -0.8)
	probe.size = Vector3(18, 6, 14)
	probe.update_mode = ReflectionProbe.UPDATE_ALWAYS
	probe.interior = true
	probe.box_projection = true
	probe.intensity = 1.18
	probe.max_distance = 0.0
	probe.cull_mask = 0xFFFFFFFF
	$Clinic.add_child(probe)

func _add_exterior_reflection_probe(exterior: Node3D) -> void:
	if exterior.has_node("ExteriorReflectionProbe"):
		return
	var probe := ReflectionProbe.new()
	probe.name = "ExteriorReflectionProbe"
	probe.position = Vector3(0, 3.6, 0)
	probe.size = Vector3(124, 14, 124)
	probe.box_projection = true
	probe.update_mode = ReflectionProbe.UPDATE_ONCE
	probe.intensity = 0.9
	exterior.add_child(probe)

func _add_post_fx_overlay() -> void:
	if $CanvasLayer.has_node("PostFxOverlay"):
		return
	var overlay: ColorRect = ColorRect.new()
	overlay.name = "PostFxOverlay"
	overlay.color = Color(1, 1, 1, 1)
	overlay.layout_mode = 1
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader: Shader = Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float vignette_strength = 0.22;
uniform float grain_strength = 0.02;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 col = textureLod(screen_tex, uv, 0.0);
	float dist = distance(uv, vec2(0.5));
	float vig = smoothstep(0.26, 0.82, dist);
	float grain = (hash(uv * vec2(1920.0, 1080.0) + TIME) - 0.5) * grain_strength;
	col.rgb = col.rgb * (1.0 - vig * vignette_strength) + grain;
	COLOR = vec4(col.rgb, 1.0);
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	overlay.material = mat
	$CanvasLayer.add_child(overlay)
	$CanvasLayer.move_child(overlay, 0)

func _reset_progress_defaults() -> void:
	day = 1
	cash = 1800
	reputation = 1
	queue_size = 4
	day_goal_cases = 4
	day_cases_done = 0
	total_cases_served = 0
	streak = 0
	satisfaction = 75
	clinic_score = 0
	total_earnings = 0
	failed_cases = 0
	reception_level = 1
	exam_level = 1
	treatment_level = 1
	game_won = false
	game_lost = false
	unlocked = {
		"first_case": false,
		"streak_5": false,
		"rich_5000": false,
		"rep_10": false
	}
	case_state = CaseState.IDLE
	current_case = {}
	case_elapsed = 0.0

func _setup_clinic_positions() -> void:
	worker.global_position = reception_point.global_position
	patient.global_position = entrance_point.global_position
	patient.visible = false

func _setup_runtime_ui() -> void:
	objective_label = Label.new()
	objective_label.text = "Hedef: -"
	$CanvasLayer/HUD/TopBar.add_child(objective_label)

	help_label = Label.new()
	help_label.text = "F5 Kaydet | F9 Yukle | P Duraklat"
	help_label.position = Vector2(20, 332)
	$CanvasLayer/HUD.add_child(help_label)

	achievement_label = Label.new()
	achievement_label.text = "Basarim: -"
	achievement_label.position = Vector2(20, 360)
	$CanvasLayer/HUD.add_child(achievement_label)

	emergency_button = Button.new()
	emergency_button.text = "Acil Protokol"
	emergency_button.disabled = true
	actions_container.add_child(emergency_button)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			_save_game()
			status_label.text = "Durum: Oyun kaydedildi."
		elif event.keycode == KEY_F9:
			if _load_game(true):
				status_label.text = "Durum: Kayit yuklendi."
		elif event.keycode == KEY_P:
			get_tree().paused = not get_tree().paused
			if get_tree().paused:
				status_label.text = "Durum: Oyun duraklatildi."
			else:
				status_label.text = "Durum: Oyun devam ediyor."
		elif event.keycode == KEY_ESCAPE:
			_save_game()
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _process(delta: float) -> void:
	_update_day_night(delta)
	_update_ambient_world(delta)
	integrity_check_timer += delta
	if integrity_check_timer > 2.5:
		integrity_check_timer = 0.0
		_ensure_visual_integrity()

	if game_won or game_lost:
		_refresh_ui()
		return

	var worker_moving: bool = false
	var patient_moving: bool = false

	if case_state in [CaseState.TO_RECEPTION, CaseState.CHECKIN, CaseState.TO_EXAM, CaseState.WAIT_DIAGNOSIS, CaseState.TO_TREATMENT, CaseState.WAIT_TREATMENT, CaseState.DISCHARGE]:
		case_elapsed += delta
		if case_state in [CaseState.WAIT_DIAGNOSIS, CaseState.WAIT_TREATMENT] and case_elapsed > case_deadline:
			_fail_current_case("Sure asimi")

	match case_state:
		CaseState.TO_RECEPTION:
			var worker_done: bool = _move_actor(worker, worker_target, _worker_speed(), delta)
			var patient_done: bool = _move_actor(patient, patient_target, _patient_speed(), delta)
			worker_moving = not worker_done
			patient_moving = not patient_done
			if worker_done and patient_done:
				case_state = CaseState.CHECKIN
				interaction_timer = max(0.5, 1.4 - reception_level * 0.15)
				status_label.text = "Durum: Resepsiyonda kayit yapiliyor."

		CaseState.CHECKIN:
			interaction_timer -= delta
			if interaction_timer <= 0.0:
				case_state = CaseState.TO_EXAM
				worker_target = exam_point.global_position
				patient_target = exam_point.global_position + Vector3(0.6, 0, 0.0)
				status_label.text = "Durum: Muayene odasina geciliyor."

		CaseState.TO_EXAM:
			var worker_done: bool = _move_actor(worker, worker_target, _worker_speed(), delta)
			var patient_done: bool = _move_actor(patient, patient_target, _patient_speed(), delta)
			worker_moving = not worker_done
			patient_moving = not patient_done
			if worker_done and patient_done:
				case_state = CaseState.WAIT_DIAGNOSIS
				status_label.text = "Durum: Muayene hazir. Teshis baslat."

		CaseState.TO_TREATMENT:
			var worker_done: bool = _move_actor(worker, worker_target, _worker_speed(), delta)
			var patient_done: bool = _move_actor(patient, patient_target, _patient_speed(), delta)
			worker_moving = not worker_done
			patient_moving = not patient_done
			if worker_done and patient_done:
				case_state = CaseState.WAIT_TREATMENT
				status_label.text = "Durum: Tedavi odasi hazir. Tedavi uygula."

		CaseState.DISCHARGE:
			var worker_done: bool = _move_actor(worker, worker_target, _worker_speed(), delta)
			var patient_done: bool = _move_actor(patient, patient_target, _patient_speed(), delta)
			worker_moving = not worker_done
			patient_moving = not patient_done
			if worker_done and patient_done:
				_finalize_case_cycle()

	_animate_actor(worker, worker_visual_root, worker_target, worker_moving, delta, 1.0)
	_animate_actor(patient, patient_visual_root, patient_target, patient_moving, delta, 0.8)
	_update_achievements()
	_refresh_ui()
	_check_end_conditions()

func _ensure_visual_integrity() -> void:
	if not has_node("Exterior"):
		_build_exterior_world()

	if worker_visual_root.get_child_count() == 0:
		_replace_visual(worker_visual_root, "res://assets/models/vet_character.glb", Vector3(1.0, 1.0, 1.0), 180.0)
	if patient_visual_root.get_child_count() == 0:
		_replace_visual(patient_visual_root, "res://assets/models/pet_character.glb", Vector3(1.2, 1.2, 1.2), 180.0)

	if counter_anchor.get_child_count() == 0:
		_spawn_prop("res://assets/models/counter.glb", counter_anchor, Vector3(1.0, 1.0, 1.0), 90.0)
	if exam_table_anchor.get_child_count() == 0:
		_spawn_prop("res://assets/models/exam_table.glb", exam_table_anchor, Vector3(1.0, 1.0, 1.0), 0.0)
	if shelf_anchor.get_child_count() == 0:
		_spawn_prop("res://assets/models/shelf.glb", shelf_anchor, Vector3(1.0, 1.0, 1.0), 180.0)
	if cart_anchor.get_child_count() == 0:
		_spawn_prop("res://assets/models/medicine_cart.glb", cart_anchor, Vector3(0.7, 0.7, 0.7), 45.0)
	if plant_anchor.get_child_count() == 0:
		_spawn_prop("res://assets/models/plant.glb", plant_anchor, Vector3(1.1, 1.1, 1.1), 0.0)

func _update_ambient_world(delta: float) -> void:
	for car_data in exterior_cars:
		var car: Node3D = car_data["node"]
		var speed: float = float(car_data["speed"])
		var dir: float = float(car_data["dir"])
		var axis: String = String(car_data["axis"])
		var min_v: float = float(car_data["min_v"])
		var max_v: float = float(car_data["max_v"])
		if axis == "x":
			car.position.x += speed * dir * delta
			if car.position.x > max_v:
				car.position.x = min_v
			elif car.position.x < min_v:
				car.position.x = max_v
		else:
			car.position.z += speed * dir * delta
			if car.position.z > max_v:
				car.position.z = min_v
			elif car.position.z < min_v:
				car.position.z = max_v

	for walker_data in exterior_walkers:
		var walker: Node3D = walker_data["node"]
		var speed: float = float(walker_data["speed"])
		var dir: float = float(walker_data["dir"])
		var axis: String = String(walker_data["axis"])
		var min_v: float = float(walker_data["min_v"])
		var max_v: float = float(walker_data["max_v"])
		var phase: float = float(walker_data["phase"])
		phase += delta * 6.0
		walker_data["phase"] = phase

		if axis == "x":
			walker.position.x += speed * dir * delta
			if walker.position.x > max_v:
				walker.position.x = min_v
			elif walker.position.x < min_v:
				walker.position.x = max_v
		else:
			walker.position.z += speed * dir * delta
			if walker.position.z > max_v:
				walker.position.z = min_v
			elif walker.position.z < min_v:
				walker.position.z = max_v
		walker.position.y = sin(phase) * 0.03

func _update_day_night(delta: float) -> void:
	day_night_time = fmod(day_night_time + delta * 0.0016, 1.0)
	var sun_angle: float = day_night_time * TAU
	var sun_height: float = sin(sun_angle)
	var day_factor: float = clamp((sun_height + 0.34) / 1.24, 0.0, 1.0)
	var dusk_factor: float = clamp(1.0 - abs(sun_height) * 1.8, 0.0, 1.0)
	var night_factor: float = 1.0 - day_factor

	sun_light.rotation_degrees.x = lerp(-130.0, -15.0, day_factor)
	sun_light.rotation_degrees.y = 30.0 + cos(sun_angle) * 85.0
	sun_light.light_energy = lerp(0.22, 1.95, day_factor)
	sun_light.light_color = Color(0.43, 0.51, 0.74).lerp(Color(1.0, 0.95, 0.86), day_factor).lerp(Color(1.0, 0.66, 0.44), dusk_factor * 0.22)

	if world_environment.environment:
		var env: Environment = world_environment.environment
		env.background_color = Color(0.08, 0.11, 0.18).lerp(Color(0.64, 0.78, 0.95), day_factor)
		env.ambient_light_energy = lerp(0.38, 1.0, day_factor)
		env.tonemap_exposure = lerp(0.95, 1.12, day_factor)
		env.set("fog_density", lerp(0.014, 0.006, day_factor))
		env.set("volumetric_fog_density", lerp(0.028, 0.018, day_factor))

	if asphalt_material:
		asphalt_material.set_shader_parameter("wetness", lerp(0.55, 0.16, day_factor))

	var street_energy: float = lerp(1.9, 0.14, day_factor)
	for street in exterior_street_lights:
		street.light_energy = street_energy

	for win in exterior_window_meshes:
		if win.material_override is StandardMaterial3D:
			var mat: StandardMaterial3D = win.material_override as StandardMaterial3D
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.83, 0.56)
			mat.emission_energy_multiplier = lerp(2.4, 0.2, day_factor)

	if billboard_screen_mat:
		billboard_screen_mat.emission_enabled = true
		billboard_screen_mat.emission = Color(0.2, 0.6, 1.0)
		billboard_screen_mat.emission_energy_multiplier = lerp(2.8, 0.55, day_factor)

	reception_light.light_energy = lerp(0.42, 1.35, day_factor)
	exam_light.light_energy = lerp(0.45, 1.46, day_factor)
	treatment_light.light_energy = lerp(0.45, 1.42, day_factor)

func _move_actor(actor: Node3D, target: Vector3, speed: float, delta: float) -> bool:
	var delta_vec: Vector3 = target - actor.global_position
	var distance: float = delta_vec.length()
	if distance <= ARRIVE_EPS:
		actor.global_position = target
		return true
	actor.global_position += delta_vec.normalized() * min(distance, speed * delta)
	return false

func _worker_speed() -> float:
	return BASE_WORKER_SPEED + float(reception_level + exam_level + treatment_level - 3) * 0.15

func _patient_speed() -> float:
	return BASE_PATIENT_SPEED + float(reception_level) * 0.05

func _severity_multiplier(severity: String) -> float:
	if severity == "Acil":
		return 1.45
	if severity == "Kritik":
		return 1.8
	return 1.0

func _generate_case() -> void:
	var symptom: String = symptoms[randi() % symptoms.size()]
	var severity_roll: float = randf()
	var severity: String = "Normal"
	if severity_roll < min(0.15 + float(day) * 0.015, 0.42):
		severity = "Kritik"
	elif severity_roll < min(0.35 + float(day) * 0.02, 0.78):
		severity = "Acil"

	var base_deadline: float = 30.0 - float(day) * 0.4
	if severity == "Acil":
		base_deadline -= 5.0
	elif severity == "Kritik":
		base_deadline -= 8.0
	case_deadline = max(10.0, base_deadline + float(reception_level) * 0.7)
	case_elapsed = 0.0

	current_case = {
		"pet": pets[randi() % pets.size()],
		"symptom": symptom,
		"treatment": correct_treatments[symptom],
		"severity": severity,
		"diagnosis_ok": false
	}

func _start_case() -> void:
	if queue_size <= 0 or game_won or game_lost:
		return
	_generate_case()
	patient.visible = true
	patient.global_position = entrance_point.global_position
	worker_target = reception_point.global_position + Vector3(-0.6, 0, 0)
	patient_target = reception_point.global_position + Vector3(0.7, 0, 0)
	case_state = CaseState.TO_RECEPTION
	status_label.text = "Durum: Yeni vaka kabul edildi."

func _finalize_case_cycle() -> void:
	queue_size -= 1
	day_cases_done += 1
	total_cases_served += 1
	patient.visible = false
	case_state = CaseState.IDLE
	current_case = {}
	case_elapsed = 0.0
	_update_achievements()

	if queue_size <= 0:
		_close_day_and_start_next()
	else:
		status_label.text = "Durum: Vaka tamamlandi. Yeni hasta cagir."

func _close_day_and_start_next() -> void:
	var passive_income: int = 80 + reception_level * 35
	var staff_cost: int = 170 + day * 10
	cash += passive_income - staff_cost
	total_earnings += max(0, passive_income - staff_cost)

	if day_cases_done >= day_goal_cases:
		reputation += 2
		satisfaction = min(100, satisfaction + 2)
		clinic_score += 120
	else:
		reputation = max(1, reputation - 1)
		satisfaction = max(0, satisfaction - 4)
		clinic_score = max(0, clinic_score - 60)

	day += 1
	_start_new_day(false)
	_apply_daily_event()
	_save_game()

func _start_new_day(initial: bool) -> void:
	if not initial:
		status_label.text = "Durum: Gun %d basladi." % day
	queue_size = 4 + int(day / 2)
	day_goal_cases = 3 + int(day / 2)
	day_cases_done = 0
	streak = 0

func _apply_daily_event() -> void:
	var roll: float = randf()
	if roll < 0.22:
		var bonus: int = 220 + day * 12
		cash += bonus
		total_earnings += bonus
		status_label.text = "Durum: Sigorta odemesi geldi (+$%d)." % bonus
	elif roll < 0.38:
		var penalty: int = 160 + day * 8
		cash -= penalty
		satisfaction = max(0, satisfaction - 3)
		status_label.text = "Durum: Tedarik gecikti (-$%d)." % penalty
	elif roll < 0.5:
		reputation += 1
		satisfaction = min(100, satisfaction + 4)
		status_label.text = "Durum: Sosyal medya ovgusu. Itibar artti."

func _fail_current_case(reason: String) -> void:
	failed_cases += 1
	streak = 0
	satisfaction = max(0, satisfaction - 8)
	reputation = max(1, reputation - 1)
	clinic_score = max(0, clinic_score - 45)
	cash -= 90

	worker_target = reception_point.global_position + Vector3(-0.4, 0, 0)
	patient_target = exit_point.global_position
	case_state = CaseState.DISCHARGE
	status_label.text = "Durum: Vaka basarisiz (%s)." % reason

func _room_status(room_name: String) -> String:
	match room_name:
		"reception":
			if case_state in [CaseState.TO_RECEPTION, CaseState.CHECKIN]:
				return "Mesgul"
		"exam":
			if case_state in [CaseState.TO_EXAM, CaseState.WAIT_DIAGNOSIS]:
				return "Mesgul"
		"treatment":
			if case_state in [CaseState.TO_TREATMENT, CaseState.WAIT_TREATMENT]:
				return "Mesgul"
	return "Bos"

func _refresh_ui() -> void:
	day_label.text = "Gun: %d" % day
	cash_label.text = "Nakit: $%d" % cash
	reputation_label.text = "Itibar: %d" % reputation
	queue_label.text = "Kuyruk: %d/%d" % [day_cases_done, day_goal_cases]
	streak_label.text = "Seri: x%d" % streak
	satisfaction_label.text = "Memnuniyet: %d" % satisfaction

	pet_label.text = "Hasta: %s" % String(current_case.get("pet", "-"))
	symptom_label.text = "Belirti: %s" % String(current_case.get("symptom", "-"))
	treatment_label.text = "Tedavi: %s" % String(current_case.get("treatment", "-"))
	severity_label.text = "Oncelik: %s | Kalan sure: %.1fs" % [String(current_case.get("severity", "-")), max(0.0, case_deadline - case_elapsed)]

	reception_room_label.text = "Resepsiyon: %s (Lv.%d)" % [_room_status("reception"), reception_level]
	exam_room_label.text = "Muayene Odasi: %s (Lv.%d)" % [_room_status("exam"), exam_level]
	treatment_room_label.text = "Tedavi Odasi: %s (Lv.%d)" % [_room_status("treatment"), treatment_level]

	reception_upgrade_label.text = "Resepsiyon Lv.%d | Maliyet: $%d" % [reception_level, _upgrade_cost(reception_level)]
	exam_upgrade_label.text = "Muayene Lv.%d | Maliyet: $%d" % [exam_level, _upgrade_cost(exam_level)]
	treatment_upgrade_label.text = "Tedavi Lv.%d | Maliyet: $%d" % [treatment_level, _upgrade_cost(treatment_level)]

	objective_label.text = "Hedef: Itibar 25, Nakit $12000 | Skor: %d" % clinic_score
	achievement_label.text = "Basarim: %d/4" % _achievement_count()

	diagnose_button.disabled = case_state != CaseState.WAIT_DIAGNOSIS or game_won or game_lost
	treat_button.disabled = case_state != CaseState.WAIT_TREATMENT or game_won or game_lost
	next_case_button.disabled = case_state != CaseState.IDLE or queue_size <= 0 or game_won or game_lost
	emergency_button.disabled = case_state != CaseState.WAIT_TREATMENT or String(current_case.get("severity", "")) == "Normal" or game_won or game_lost

	reception_upgrade_button.disabled = cash < _upgrade_cost(reception_level) or game_won or game_lost
	exam_upgrade_button.disabled = cash < _upgrade_cost(exam_level) or game_won or game_lost
	treatment_upgrade_button.disabled = cash < _upgrade_cost(treatment_level) or game_won or game_lost

func _diagnosis_success() -> bool:
	var severity: String = String(current_case.get("severity", "Normal"))
	var chance: float = 0.58 + float(exam_level) * 0.08 + float(reputation) * 0.004
	if severity == "Acil":
		chance -= 0.13
	elif severity == "Kritik":
		chance -= 0.2
	chance = clamp(chance, 0.2, 0.95)
	return randf() <= chance

func _treatment_success(emergency_mode: bool) -> bool:
	var severity: String = String(current_case.get("severity", "Normal"))
	var diagnosis_ok: bool = bool(current_case.get("diagnosis_ok", false))
	var chance: float = 0.55 + float(treatment_level) * 0.09
	if diagnosis_ok:
		chance += 0.17
	if emergency_mode:
		chance += 0.22
	if severity == "Kritik":
		chance -= 0.16
	elif severity == "Acil":
		chance -= 0.09
	chance = clamp(chance, 0.15, 0.96)
	return randf() <= chance

func _on_diagnose_pressed() -> void:
	if case_state != CaseState.WAIT_DIAGNOSIS:
		return
	var ok: bool = _diagnosis_success()
	current_case["diagnosis_ok"] = ok
	if ok:
		reputation += 1
		satisfaction = min(100, satisfaction + 1)
		status_label.text = "Durum: Dogru teshis. Tedavi odasina geciliyor."
	else:
		reputation = max(1, reputation - 1)
		status_label.text = "Durum: Supheli teshis. Dikkatli tedavi et."

	worker_target = treatment_point.global_position + Vector3(-0.3, 0, 0)
	patient_target = treatment_point.global_position + Vector3(0.6, 0, 0)
	case_state = CaseState.TO_TREATMENT

func _complete_treatment(emergency_mode: bool) -> void:
	if case_state != CaseState.WAIT_TREATMENT:
		return

	var success: bool = _treatment_success(emergency_mode)
	if success:
		var severity: String = String(current_case.get("severity", "Normal"))
		var base_income: int = 210 + treatment_level * 28
		base_income = int(float(base_income) * _severity_multiplier(severity))
		if emergency_mode:
			base_income -= 60
		var combo_bonus: int = min(260, streak * 14)
		cash += base_income + combo_bonus
		total_earnings += base_income + combo_bonus
		clinic_score += 45 + combo_bonus / 2
		satisfaction = min(100, satisfaction + 2)
		reputation += 1 + int(streak / 5)
		streak += 1
		status_label.text = "Durum: Tedavi basarili. Gelir: $%d" % (base_income + combo_bonus)
	else:
		_fail_current_case("Tedavi hatasi")
		return

	worker_target = reception_point.global_position + Vector3(-0.4, 0, 0)
	patient_target = exit_point.global_position
	case_state = CaseState.DISCHARGE

func _on_treat_pressed() -> void:
	_complete_treatment(false)

func _on_emergency_protocol() -> void:
	_complete_treatment(true)

func _on_next_case_pressed() -> void:
	_start_case()

func _upgrade_cost(level: int) -> int:
	return 320 + (level - 1) * 260

func _on_upgrade_reception() -> void:
	if _purchase_upgrade("Resepsiyon", reception_level):
		reception_level += 1

func _on_upgrade_exam() -> void:
	if _purchase_upgrade("Muayene", exam_level):
		exam_level += 1

func _on_upgrade_treatment() -> void:
	if _purchase_upgrade("Tedavi", treatment_level):
		treatment_level += 1

func _purchase_upgrade(name: String, level: int) -> bool:
	var cost: int = _upgrade_cost(level)
	if cash < cost:
		return false
	cash -= cost
	clinic_score += 90
	satisfaction = min(100, satisfaction + 3)
	status_label.text = "Durum: %s alani Lv.%d oldu." % [name, level + 1]
	return true

func _check_end_conditions() -> void:
	if game_won or game_lost:
		return

	if reputation >= 25 and cash >= 12000 and clinic_score >= 3000:
		game_won = true
		status_label.text = "Durum: Tebrikler. Klinik premium seviyeye ulasti!"
		_save_game()
		return

	if satisfaction <= 10 or cash <= -800:
		game_lost = true
		status_label.text = "Durum: Klinik kapandi. F9 ile kayit yukleyebilirsin."

func _update_achievements() -> void:
	if total_cases_served >= 1:
		unlocked["first_case"] = true
	if streak >= 5:
		unlocked["streak_5"] = true
	if cash >= 5000:
		unlocked["rich_5000"] = true
	if reputation >= 10:
		unlocked["rep_10"] = true

func _achievement_count() -> int:
	var count := 0
	for key in unlocked.keys():
		if bool(unlocked[key]):
			count += 1
	return count

func _spawn_props() -> void:
	_spawn_prop("res://assets/models/counter.glb", counter_anchor, Vector3(1.0, 1.0, 1.0), 90.0)
	_spawn_prop("res://assets/models/exam_table.glb", exam_table_anchor, Vector3(1.0, 1.0, 1.0), 0.0)
	_spawn_prop("res://assets/models/shelf.glb", shelf_anchor, Vector3(1.0, 1.0, 1.0), 180.0)
	_spawn_prop("res://assets/models/medicine_cart.glb", cart_anchor, Vector3(0.7, 0.7, 0.7), 45.0)
	_spawn_prop("res://assets/models/plant.glb", plant_anchor, Vector3(1.1, 1.1, 1.1), 0.0)
	_spawn_prop_at("res://assets/models/chair.glb", Vector3(-7.1, 0.0, 3.2), Vector3(1.0, 1.0, 1.0), 10.0)
	_spawn_prop_at("res://assets/models/chair.glb", Vector3(-6.0, 0.0, 3.3), Vector3(1.0, 1.0, 1.0), -8.0)
	_spawn_prop_at("res://assets/models/chair.glb", Vector3(-4.8, 0.0, 3.2), Vector3(1.0, 1.0, 1.0), 6.0)
	_spawn_prop_at("res://assets/models/monitor.glb", Vector3(-6.25, 1.08, 1.3), Vector3(1.0, 1.0, 1.0), 180.0)
	_spawn_prop_at("res://assets/models/pet_cage.glb", Vector3(7.2, 0.0, -2.6), Vector3(1.0, 1.0, 1.0), -90.0)
	_spawn_prop_at("res://assets/models/pet_cage.glb", Vector3(7.2, 0.0, -1.3), Vector3(1.0, 1.0, 1.0), -90.0)
	_spawn_prop_at("res://assets/models/lamp.glb", Vector3(-5.8, 0.0, 0.5), Vector3(1.3, 1.3, 1.3), 0.0)
	_spawn_prop_at("res://assets/models/lamp.glb", Vector3(0.0, 0.0, -3.2), Vector3(1.2, 1.2, 1.2), 0.0)
	_spawn_prop_at("res://assets/models/lamp.glb", Vector3(6.0, 0.0, 0.8), Vector3(1.2, 1.2, 1.2), 0.0)

func _spawn_prop(path: String, anchor: Node3D, scale_value: Vector3, rot_y_deg: float) -> void:
	var scene_res: Resource = load(path)
	if scene_res is PackedScene:
		var instance: Node = (scene_res as PackedScene).instantiate()
		anchor.add_child(instance)
		if instance is Node3D:
			(instance as Node3D).scale = scale_value
			(instance as Node3D).rotation_degrees.y = rot_y_deg
	else:
		var fallback := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.8, 0.8, 0.8)
		fallback.mesh = mesh
		anchor.add_child(fallback)

func _spawn_prop_at(path: String, world_pos: Vector3, scale_value: Vector3, rot_y_deg: float) -> void:
	var anchor := Node3D.new()
	props_root.add_child(anchor)
	anchor.global_position = world_pos
	_spawn_prop(path, anchor, scale_value, rot_y_deg)

func _spawn_characters() -> void:
	_replace_visual(worker_visual_root, "res://assets/models/vet_character.glb", Vector3(1.0, 1.0, 1.0), 180.0)
	_replace_visual(patient_visual_root, "res://assets/models/pet_character.glb", Vector3(1.2, 1.2, 1.2), 180.0)

func _replace_visual(root: Node3D, path: String, scale_value: Vector3, rot_y_deg: float) -> void:
	for child in root.get_children():
		child.queue_free()
	var scene_res: Resource = load(path)
	if scene_res is PackedScene:
		var instance: Node = (scene_res as PackedScene).instantiate()
		root.add_child(instance)
		if instance is Node3D:
			(instance as Node3D).scale = scale_value
			(instance as Node3D).rotation_degrees.y = rot_y_deg
	else:
		var fallback := MeshInstance3D.new()
		fallback.mesh = CapsuleMesh.new()
		root.add_child(fallback)

func _animate_actor(actor: Node3D, visual_root: Node3D, target: Vector3, is_moving: bool, delta: float, amp: float) -> void:
	if is_moving:
		walk_cycle += delta * 9.0
		visual_root.position.y = 0.02 + sin(walk_cycle) * 0.04 * amp
		var heading: Vector3 = target - actor.global_position
		if heading.length() > 0.01:
			actor.rotation.y = lerp_angle(actor.rotation.y, atan2(heading.x, heading.z), 0.2)
	else:
		visual_root.position.y = lerp(visual_root.position.y, 0.02, 0.15)

func _save_game() -> void:
	var data: Dictionary = {
		"day": day,
		"cash": cash,
		"reputation": reputation,
		"queue_size": queue_size,
		"day_goal_cases": day_goal_cases,
		"day_cases_done": day_cases_done,
		"total_cases_served": total_cases_served,
		"streak": streak,
		"satisfaction": satisfaction,
		"clinic_score": clinic_score,
		"total_earnings": total_earnings,
		"failed_cases": failed_cases,
		"reception_level": reception_level,
		"exam_level": exam_level,
		"treatment_level": treatment_level,
		"game_won": game_won,
		"game_lost": game_lost,
		"unlocked": unlocked
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func _load_game(show_feedback: bool) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var raw: String = file.get_as_text()
	var parsed: Variant = JSON.parse_string(raw)
	if parsed == null or not (parsed is Dictionary):
		return false
	var data: Dictionary = parsed

	day = int(data.get("day", 1))
	cash = int(data.get("cash", 1800))
	reputation = int(data.get("reputation", 1))
	queue_size = int(data.get("queue_size", 4))
	day_goal_cases = int(data.get("day_goal_cases", 4))
	day_cases_done = int(data.get("day_cases_done", 0))
	total_cases_served = int(data.get("total_cases_served", 0))
	streak = int(data.get("streak", 0))
	satisfaction = int(data.get("satisfaction", 75))
	clinic_score = int(data.get("clinic_score", 0))
	total_earnings = int(data.get("total_earnings", 0))
	failed_cases = int(data.get("failed_cases", 0))
	reception_level = int(data.get("reception_level", 1))
	exam_level = int(data.get("exam_level", 1))
	treatment_level = int(data.get("treatment_level", 1))
	game_won = bool(data.get("game_won", false))
	game_lost = bool(data.get("game_lost", false))
	unlocked = data.get("unlocked", unlocked)

	case_state = CaseState.IDLE
	current_case = {}
	case_elapsed = 0.0
	patient.visible = false
	_setup_clinic_positions()

	if show_feedback:
		status_label.text = "Durum: Kayit yuklendi."
	return true
