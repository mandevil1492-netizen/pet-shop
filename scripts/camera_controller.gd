extends Camera3D

@export var target := Vector3(0, 0.6, 0)
@export var distance := 15.0
@export var min_distance := 9.0
@export var max_distance := 24.0
@export var yaw := 0.0
@export var pitch := -0.55
@export var rotate_speed := 1.6
@export var zoom_speed := 1.2

func _ready() -> void:
	_update_transform()

func _unhandled_input(event: InputEvent) -> void:
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

func _process(_delta: float) -> void:
	_update_transform()

func _update_transform() -> void:
	var offset := Vector3(0, 0, distance)
	offset = offset.rotated(Vector3.RIGHT, pitch)
	offset = offset.rotated(Vector3.UP, yaw)
	global_position = target + offset
	look_at(target, Vector3.UP)
