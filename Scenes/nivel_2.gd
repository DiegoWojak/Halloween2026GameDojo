@tool
extends Node2D

## Nivel 2: mapa de tiles con Patrol/Orbiter puestos a mano. Salida en EXIT_RECT, necesita la llave.

@export_group("Ghastly (cualquier lado)")
## Aparece en un punto al azar del mapa, lejos del jugador.
@export var ghastly_scene: PackedScene = preload("res://Prefabs/Enemies/Seeker/SeekerGhastly.tscn")
## Segundos entre apariciones. 0 = desactivado.
@export var ghastly_interval := 20.0
## Máximo de ghastly vivos a la vez.
@export var max_ghastly := 1
## Distancia mínima al jugador al aparecer.
@export var ghastly_min_distance := 350.0

@export_group("Mapa")
## Tamaño del mapa en px (donde puede aparecer el Ghastly).
@export var map_size := Vector2(1000, 1100)

@export_group("Escenas")
## Nivel siguiente al escapar. Vacío = pausa.
@export var next_level: PackedScene
@export var fade_screen: FadeScreen

const EXIT_RECT := Rect2(440, 0, 120, 40)

var _has_key := false
var _escaped := false
var _ghastly_timer := 0.0

@onready var _player: Node2D = $Player
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


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or _escaped:
		return
	var p := _player.position
	if EXIT_RECT.has_point(p):
		if _has_key:
			_escape()
			return
		_label.text = "Necesitas la llave"
	if ghastly_interval > 0:
		_ghastly_timer += delta
		if _ghastly_timer >= ghastly_interval:
			_ghastly_timer = 0.0
			if get_tree().get_nodes_in_group("ghastly").size() < max_ghastly:
				_spawn_ghastly(p)


func _escape() -> void:
	_escaped = true
	_label.text = "¡Escapaste!"
	if fade_screen:
		await fade_screen.fade_to_black()
	if next_level:
		get_tree().change_scene_to_packed(next_level)
	else:
		get_tree().paused = true


func _spawn_ghastly(player_pos: Vector2) -> void:
	var pos := player_pos
	for i in 20: # ponytail: muestreo al azar; si el mapa es chico puede quedar más cerca que ghastly_min_distance
		pos = Vector2(randf() * map_size.x, randf() * map_size.y)
		if pos.distance_to(player_pos) >= ghastly_min_distance:
			break
	var g := ghastly_scene.instantiate()
	g.position = pos
	g.add_to_group("ghastly")
	add_child(g)
