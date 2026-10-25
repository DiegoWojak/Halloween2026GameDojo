class_name MainMenu extends Node

@export var fade_screen: FadeScreen

@export var button_play: BaseButton
@export var button_options: BaseButton
@export var button_credits: BaseButton
@export var button_exit: BaseButton

@export var buttons_back: Array[BaseButton]

@export var next_scene: PackedScene

@export var main_panel: Control
@export var options_panel: Control
@export var credits_panel: Control

@export var slider_master: HSlider
@export var slider_music: HSlider
@export var slider_sfx: HSlider
## Guarda los volúmenes en SETTINGS_PATH y vuelve al menú.
@export var button_save: BaseButton

const SETTINGS_PATH := "user://settings.cfg"

static var _base_db := {}

func _ready() -> void:
	main_panel.visible = true
	options_panel.visible = false
	credits_panel.visible = false

	fade_screen.fade_to_image()
	button_play.pressed.connect(func():
		await fade_screen.fade_to_black()
		get_tree().change_scene_to_packed(next_scene))

	button_options.pressed.connect(func():
		await fade_screen.fade_to_black()
		main_panel.visible = false
		options_panel.visible = true
		fade_screen.fade_to_image()
		)

	button_credits.pressed.connect(func():
		await fade_screen.fade_to_black()
		main_panel.visible = false
		credits_panel.visible = true
		fade_screen.fade_to_image()
		)

	button_exit.pressed.connect(func():
		await fade_screen.fade_to_black()
		get_tree().quit()
		)

	for item: BaseButton in buttons_back:
		item.pressed.connect(_back)

	slider_master.value_changed.connect(_set_bus_volume.bind(&"Master"))
	slider_music.value_changed.connect(_set_bus_volume.bind(&"Music"))
	slider_sfx.value_changed.connect(_set_bus_volume.bind(&"Effects"))
	_load_volumes() # después de conectar: mover los sliders aplica el volumen a los buses

	button_save.pressed.connect(func():
		_save_volumes()
		_back())


func _back() -> void:
	if main_panel.visible == true: return
	await fade_screen.fade_to_black()
	main_panel.visible = true
	options_panel.visible = false
	credits_panel.visible = false
	fade_screen.fade_to_image()


## Slider 1.0 = volumen base del bus (default_bus_layout.tres), no 0 dB.
func _set_bus_volume(value: float, bus: StringName) -> void:
	var i := AudioServer.get_bus_index(bus)
	if not _base_db.has(bus): # se lee una vez, antes de que un slider lo cambie
		_base_db[bus] = AudioServer.get_bus_volume_db(i)
	AudioServer.set_bus_volume_db(i, _base_db[bus] + linear_to_db(value))


func _save_volumes() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", slider_master.value)
	cfg.set_value("audio", "music", slider_music.value)
	cfg.set_value("audio", "sfx", slider_sfx.value)
	cfg.save(SETTINGS_PATH)


func _load_volumes() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	slider_master.value = cfg.get_value("audio", "master", slider_master.value)
	slider_music.value = cfg.get_value("audio", "music", slider_music.value)
	slider_sfx.value = cfg.get_value("audio", "sfx", slider_sfx.value)
