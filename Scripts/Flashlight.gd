class_name Flashlight extends Node2D
## Linterna con dos luces (ConeLight) que comparten la misma energía:
## - Normal (flashlight_toggle, Espacio): largo alcance; muros, objetos y enemigos sin id.
## - Ultravioleta (flashlight_swap, clic izq.): menos alcance y más intensa; además revela
##   los enemigos de light_only_ids y los objetos "secret".
## Pulsar la tecla de la luz encendida la apaga; la otra cambia de luz.
## Apunta hacia la propiedad `facing` (Vector2) del padre si existe; si no, al mouse.

@export var light_normal: ConeLight
## Luz ultravioleta.
@export var light_secret: ConeLight
## Opcional: acompaña a la luz normal, más larga y tenue, para ver más lejos.
## Como la normal, no revela los enemigos de light_only_ids.
@export var light_outer: ConeLight
## Qué tan rápido gira hacia `facing` (más alto = más rápido).
@export var turn_speed := 10.0
var is_light_normal: bool = true

@export_group("Energy")
@export var max_energy: float = 100.0
## Energía por segundo que gasta encendida (cualquiera de las dos luces).
@export var drain_rate: float = 20.0
## Energía por segundo que recupera apagada.
@export var recharge_rate: float = 12.0
## Barra opcional (ProgressBar, TextureProgressBar...) que muestra la energía.
@export var energy_bar: Range
## class_name de enemigos que solo revela la luz ultravioleta (light_secret).
@export var light_only_ids: Array[StringName] = [&"Orbiter"]
## Capa de luz de los enemigos en light_only_ids. Debe estar en el
## range_item_cull_mask de light_secret y fuera del de light_normal.
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
	var parent := get_parent()
	if "facing" in parent:
		# lerp_angle toma el camino corto y frena al llegar (ease-out)
		rotation = lerp_angle(rotation, (parent.facing as Vector2).angle(), 1.0 - exp(-turn_speed * delta))
	else:
		look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("flashlight_toggle"):
		_switch(true)
	if Input.is_action_just_pressed("flashlight_swap"):
		_switch(false)

	energy = clampf(energy + (-drain_rate if is_on else recharge_rate) * delta, 0.0, max_energy)
	if energy == 0.0:
		is_on = false
	if energy_bar:
		energy_bar.value = energy

	light_normal.visible = is_on and is_light_normal
	light_secret.visible = is_on and not is_light_normal
	if light_outer:
		light_outer.visible = is_on and is_light_normal
	var secret_visible := is_on and not is_light_normal
	if secret_visible != _secret_shown:
		_secret_shown = secret_visible
		GlobalManager.secret_toggle_visibility(secret_visible)

	# Fuera de la luz todo es oscuridad: los enemigos usan material normal (CanvasModulate negro).
	# Los de light_only_ids van a su propia capa y en LIGHT_ONLY, así no dejan silueta negra
	# sobre el piso iluminado por la luz normal.
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var script := enemy.get_script() as Script
		if script and script.get_global_name() in light_only_ids:
			for item in [enemy] + enemy.get_children():
				if item is CanvasItem and (item.material == null or item.material is CanvasItemMaterial):
					item.light_mask = id_light_mask
					item.material = _light_only_mat

## Enciende la luz pedida (normal o UV); si ya estaba encendida, la apaga.
func _switch(normal: bool) -> void:
	if is_on and is_light_normal == normal:
		is_on = false
	elif energy > 0:
		is_on = true
		is_light_normal = normal

## Luz encendida en este momento, o null si está apagada.
func active_light() -> ConeLight:
	if not is_on:
		return null
	return light_normal if is_light_normal else light_secret
