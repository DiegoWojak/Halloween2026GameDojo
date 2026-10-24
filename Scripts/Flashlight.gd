class_name Flashlight extends Node2D

@export var light_normal: PointLight2D
@export var light_secret: PointLight2D
var is_light_normal: bool = true

@export_group("Energy")
@export var max_energy: float = 100.0
## Energía por segundo que gasta encendida.
@export var drain_rate: float = 20.0
## Energía por segundo que recupera apagada.
@export var recharge_rate: float = 12.0
## Barra opcional (ProgressBar, TextureProgressBar...) que muestra la energía.
@export var energy_bar: Range
## Alpha de los nodos del grupo "enemies" con la luz apagada.
@export var enemy_alpha_off: float = 0.1

var is_on: bool = true
var energy: float
var _secret_shown: bool = false

func _ready() -> void:
	energy = max_energy
	if energy_bar:
		energy_bar.max_value = max_energy

func _process(delta: float):
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("flashlight_swap"):
		is_light_normal = not is_light_normal
	if Input.is_action_just_pressed("flashlight_toggle") and (is_on or energy > 0):
		is_on = not is_on

	energy = clampf(energy + (-drain_rate if is_on else recharge_rate) * delta, 0.0, max_energy)
	if energy == 0.0:
		is_on = false
	if energy_bar:
		energy_bar.value = energy

	light_normal.visible = is_on and is_light_normal
	light_secret.visible = is_on and not is_light_normal
	var secret_visible := is_on and not is_light_normal
	if secret_visible != _secret_shown:
		_secret_shown = secret_visible
		GlobalManager.secret_toggle_visibility(secret_visible)

	var alpha := 1.0 if is_on else enemy_alpha_off
	for enemy in get_tree().get_nodes_in_group("enemies"):
		(enemy as CanvasItem).modulate.a = alpha
