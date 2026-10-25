@tool
extends Node2D

## Nivel 2: mapa de tiles con Patrol/Orbiter puestos a mano. Salida = Area2D, necesita la llave.

@export_group("Escenas")
## Nivel siguiente al escapar. Vacío = vuelve a `menu`.
@export var next_level: PackedScene
@export var menu: PackedScene
@export var fade_screen: FadeScreen

var _has_key := false
var _escaped := false

@onready var _label: Label = $HUD/Label


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for key in get_tree().get_nodes_in_group("keys"):
		key.collected.connect(_on_key_collected)
	_label.text = "Busca la llave"
	if fade_screen:
		await fade_screen.fade_to_image()


func _on_key_collected() -> void:
	_has_key = true
	_label.text = "¡Tienes la llave! Ve a la salida"


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is Jugador or _escaped:
		return
	if not _has_key:
		_label.text = "Necesitas la llave"
		return
	_escaped = true
	_label.text = "¡Escapaste!"
	if fade_screen:
		await fade_screen.fade_to_black()
	var next := next_level if next_level else menu
	if next:
		get_tree().change_scene_to_packed(next)
	else:
		get_tree().paused = true
