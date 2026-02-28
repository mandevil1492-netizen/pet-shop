extends Control

@onready var continue_button: Button = $Center/Panel/Margin/VBox/ContinueButton
@onready var new_game_button: Button = $Center/Panel/Margin/VBox/NewGameButton
@onready var reset_button: Button = $Center/Panel/Margin/VBox/ResetButton
@onready var fullscreen_check: CheckBox = $Center/Panel/Margin/VBox/SettingsRow/FullscreenCheck
@onready var scale_option: OptionButton = $Center/Panel/Margin/VBox/SettingsRow/ScaleOption
@onready var volume_slider: HSlider = $Center/Panel/Margin/VBox/VolumeRow/VolumeSlider
@onready var info_label: Label = $Center/Panel/Margin/VBox/InfoLabel

func _ready() -> void:
	if OS.has_environment("CAPTURE_PREVIEW"):
		AppState.request_new_game()
		get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
		return

	scale_option.clear()
	scale_option.add_item("Kalite: Yuksek", 0)
	scale_option.add_item("Kalite: Orta", 1)
	scale_option.add_item("Kalite: Performans", 2)

	continue_button.disabled = not AppState.has_save()
	fullscreen_check.button_pressed = bool(AppState.settings.get("fullscreen", false))
	volume_slider.value = float(AppState.settings.get("master_volume_db", 0.0))

	var scale := float(AppState.settings.get("render_scale", 1.0))
	if scale >= 0.98:
		scale_option.select(0)
	elif scale >= 0.79:
		scale_option.select(1)
	else:
		scale_option.select(2)

	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	scale_option.item_selected.connect(_on_scale_selected)
	volume_slider.value_changed.connect(_on_volume_changed)

	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	$Center/Panel/Margin/VBox/QuitButton.pressed.connect(_on_quit_pressed)

	info_label.text = "Hedef: Klinigi premium seviyeye tasiyip Steam hazirligina gec."

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_new_game_pressed() -> void:
	AppState.request_new_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_reset_pressed() -> void:
	AppState.delete_save()
	continue_button.disabled = true
	info_label.text = "Kayit silindi. Yeni oyun baslatabilirsin."

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_fullscreen_toggled(pressed: bool) -> void:
	AppState.settings["fullscreen"] = pressed
	AppState.save_settings()
	AppState.apply_settings()

func _on_scale_selected(index: int) -> void:
	var scale := 1.0
	if index == 1:
		scale = 0.85
	elif index == 2:
		scale = 0.7
	AppState.settings["render_scale"] = scale
	AppState.save_settings()
	AppState.apply_settings()

func _on_volume_changed(value: float) -> void:
	AppState.settings["master_volume_db"] = value
	AppState.save_settings()
	AppState.apply_settings()
