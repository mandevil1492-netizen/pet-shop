extends Camera3D

@export var target := Vector3(0, 0.6, 0)
@export var distance := 15.0
@export var min_distance := 9.0
@export var max_distance := 24.0
@export var yaw := 0.0
@export var pitch := -0.55
@export var rotate_speed := 1.6
@export var zoom_speed := 1.2
@export var fp_move_speed := 5.0
@export var fp_mouse_sensitivity := 0.0023
@export var fp_eye_height := 1.45

var first_person_enabled := false
var fp_yaw := 0.0
var fp_pitch := -0.05
var player_body: Node3D
var player_visual_root: Node3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_transform()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_V:
		set_first_person_enabled(not first_person_enabled)
		return

	if first_person_enabled:
		if event is InputEventMouseMotion:
			fp_yaw -= event.relative.x * fp_mouse_sensitivity
			fp_pitch = clamp(fp_pitch - event.relative.y * fp_mouse_sensitivity, -1.2, 1.2)
		return

	if event.is_action_pressed("ui_left"):
		yaw += 0.08
	if event.is_action_pressed("ui_right"):
		yaw -= 0.08
	if event.is_action_pressed("ui_up"):
		pitch = clamp(pitch - 0.03, -1.2, -0.2)
	if event.is_action_pressed("ui_down"):
		pitch = clamp(pitch + 0.03, -1.2, -0.2)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			distance = max(min_distance, distance - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			distance = min(max_distance, distance + zoom_speed)

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x * 0.003 * rotate_speed
		pitch = clamp(pitch - event.relative.y * 0.002 * rotate_speed, -1.2, -0.2)

	_update_transform()

func _process(delta: float) -> void:
	if first_person_enabled:
		_update_first_person(delta)
	else:
		_update_transform()

func _update_transform() -> void:
	var offset := Vector3(0, 0, distance)
	offset = offset.rotated(Vector3.RIGHT, pitch)
	offset = offset.rotated(Vector3.UP, yaw)
	global_position = target + offset
	look_at(target, Vector3.UP)

func set_player_character(body: Node3D, visual_root: Node3D) -> void:
	player_body = body
	player_visual_root = visual_root

func set_first_person_enabled(enabled: bool) -> void:
	if enabled and player_body == null:
		return
	first_person_enabled = enabled
	if first_person_enabled:
		fp_yaw = player_body.rotation.y
		fp_pitch = 0.02
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_update_transform()

func is_first_person_enabled() -> bool:
	return first_person_enabled

func _update_first_person(delta: float) -> void:
	if player_body == null:
		return

	var move_input := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		move_input.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		move_input.y += 1.0
	if Input.is_key_pressed(KEY_A):
		move_input.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		move_input.x += 1.0
	move_input = move_input.normalized()

	var forward := Vector3(sin(fp_yaw), 0.0, cos(fp_yaw))
	var right := Vector3(forward.z, 0.0, -forward.x)
	var velocity := (right * move_input.x - forward * move_input.y) * fp_move_speed
	player_body.global_position += velocity * delta
	player_body.global_position.y = 0.0

	if move_input.length() > 0.01 and player_visual_root:
		player_visual_root.global_rotation.y = fp_yaw + PI

	var eye_pos := player_body.global_position + Vector3(0, fp_eye_height, 0)
	global_position = eye_pos
	rotation = Vector3(fp_pitch, fp_yaw, 0.0)
	target = player_body.global_position + Vector3(0, 0.6, 0)
