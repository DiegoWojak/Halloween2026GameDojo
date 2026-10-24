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
		item.pressed.connect(func():
			if main_panel.visible == true: return
			await fade_screen.fade_to_black()
			main_panel.visible = true
			options_panel.visible = false
			credits_panel.visible = false
			fade_screen.fade_to_image()
			)

	slider_master.value_changed.connect(func():
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), slider_master.value))
	slider_music.value_changed.connect(func():
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), slider_master.value))
	slider_sfx.value_changed.connect(func():
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Effects"), slider_master.value))
