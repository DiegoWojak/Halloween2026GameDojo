class_name Flashlight extends Node2D

@export var light_normal: PointLight2D
@export var light_secret: PointLight2D
## Capa externa: ilumina muros, objetos y enemigos fuera de light_only_ids.
@export var light_outer: PointLight2D
var is_light_normal: bool = true

@export_group("Energy")
@export var max_energy: float = 100.0
## Energía por segundo que gasta encendida.
@export var drain_rate: float = 20.0
## Energía por segundo que recupera apagada.
@export var recharge_rate: float = 12.0
## Barra opcional (ProgressBar, TextureProgressBar...) que muestra la energía.
@export var energy_bar: Range
## class_name de enemigos que solo se ven en la capa interna (light_normal).
## Los demás (Seeker, Patrol...) se ven también en la capa externa.
@export var light_only_ids: Array[StringName] = [&"Orbiter"]
## Capa de luz de los enemigos en light_only_ids. Debe estar en el
## range_item_cull_mask de light_normal y fuera del de light_outer.
@export_flags_2d_render var id_light_mask: int = 4

var _light_only_mat := CanvasItemMaterial.new()

var is_on: bool = true
var energy: float
var _secret_shown: bool = false

func _ready() -> void:
	energy = max_energy
	add_to_group("flashlight")
	_light_only_mat.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
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
	light_outer.visible = is_on
	var secret_visible := is_on and not is_light_normal
	if secret_visible != _secret_shown:
		_secret_shown = secret_visible
		GlobalManager.secret_toggle_visibility(secret_visible)

	# Fuera de la luz todo es oscuridad: los enemigos usan material normal (CanvasModulate negro).
	# Los de light_only_ids van a su propia capa y en LIGHT_ONLY, así no dejan silueta negra
	# sobre el piso iluminado por la capa externa.
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var script := enemy.get_script() as Script
		if script and script.get_global_name() in light_only_ids:
			for item in [enemy] + enemy.get_children():
				if item is CanvasItem and (item.material == null or item.material is CanvasItemMaterial):
					item.light_mask = id_light_mask
					item.material = _light_only_mat

## Radio (px de mundo) de la capa externa, según su textura y escala en el editor.
func outer_radius() -> float:
	return light_outer.texture.get_width() * 0.5 * light_outer.texture_scale * light_outer.global_scale.x
