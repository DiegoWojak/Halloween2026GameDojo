class_name Flashlight extends Node2D

@export var light_normal: PointLight2D
@export var light_secret: PointLight2D
var is_light_normal: bool = true

func _process(_delta: float):
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("flashlight_swap"):
		is_light_normal = not is_light_normal
		light_normal.visible = is_light_normal
		light_secret.visible = not is_light_normal
		GlobalManager.secret_toggle_visibility(not is_light_normal)
