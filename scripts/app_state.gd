extends Node

const SAVE_PATH := "user://clinic_save.json"
const SETTINGS_PATH := "user://settings.json"

var start_new_game_requested: bool = false
var settings: Dictionary = {
	"master_volume_db": 0.0,
	"fullscreen": false,
	"render_scale": 1.0
}

func _ready() -> void:
	load_settings()
	apply_settings()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func request_new_game() -> void:
	start_new_game_requested = true

func consume_new_game_request() -> bool:
	var requested: bool = start_new_game_requested
	start_new_game_requested = false
	return requested

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		save_settings()
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		settings = parsed

func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))

func apply_settings() -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, float(settings.get("master_volume_db", 0.0)))
	if bool(settings.get("fullscreen", false)):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_viewport().scaling_3d_scale = float(settings.get("render_scale", 1.0))
