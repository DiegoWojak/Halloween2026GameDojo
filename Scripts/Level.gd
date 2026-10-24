@tool
extends Node2D
## Nivel genérico. Se arma en el editor arrastrando prefabs de Prefabs/Level:
## Wall / WallColumn / TopHouse (paredes), Room (cuartos), Exit (salida) y Key.
## Necesita hijos Player y HUD/Label.

@export_group("Seeker (desde cuartos)")
## Aparece al entrar a un Room, en la esquina más lejana al jugador.
@export var seeker_scene: PackedScene = preload("res://Prefabs/Enemies/Seeker/Seeker.tscn")
## Máximo de seekers normales vivos a la vez.
@export var max_seekers := 2

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
## Tamaño del mapa desde (0, 0): piso y zona donde aparece el ghastly.
@export var map_size := Vector2(1000, 1100):
	set(v):
		map_size = v
		queue_redraw()
## Textura que se repite en todo el mapa (necesita texture_repeat en el nodo).
@export var floor_texture: Texture2D:
	set(v):
		floor_texture = v
		queue_redraw()
## Escala de cada baldosa (16px * escala).
@export var floor_tile_scale := 2.0:
	set(v):
		floor_tile_scale = v
		queue_redraw()

@export_group("Escenas")
@export var next_level: PackedScene
@export var fade_screen: FadeScreen

var _has_key := false
var _escaped := false
var _rooms: Array[Room] = []
var _current_room: Room
var _ghastly_timer := 0.0

@onready var _player: Node2D = $Player
@onready var _label: Label = $HUD/Label


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_rooms.assign(get_tree().get_nodes_in_group("rooms"))
	for key in get_tree().get_nodes_in_group("keys"):
		key.collected.connect(_on_key_collected)
	for exit in get_tree().get_nodes_in_group("exits"):
		exit.body_entered.connect(_on_exit_entered)
	_label.text = "Busca la llave"
	if fade_screen:
		await fade_screen.fade_to_image()


func _on_key_collected() -> void:
	_has_key = true
	_label.text = "¡Tienes la llave! Ve a la salida"


func _on_exit_entered(body: Node2D) -> void:
	if body != _player or _escaped:
		return
	if not _has_key:
		_label.text = "Necesitas la llave"
		return
	_escaped = true
	_label.text = "¡Escapaste!"
	if fade_screen:
		await fade_screen.fade_to_black()
	if next_level:
		get_tree().change_scene_to_packed(next_level)
	else:
		get_tree().paused = true


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var p := _player.global_position
	var room := _room_at(p)
	if room != _current_room:
		_current_room = room
		if room and get_tree().get_nodes_in_group("seekers").size() < max_seekers:
			_spawn_seeker(room.rect(), p)
	if ghastly_interval > 0:
		_ghastly_timer += delta
		if _ghastly_timer >= ghastly_interval:
			_ghastly_timer = 0.0
			if get_tree().get_nodes_in_group("ghastly").size() < max_ghastly:
				_spawn_ghastly(p)


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


func _room_at(p: Vector2) -> Room:
	for r in _rooms:
		if r.rect().has_point(p):
			return r
	return null


func _spawn_seeker(room: Rect2, player_pos: Vector2) -> void:
	# Aparece en la esquina del cuarto más lejana al jugador
	var corners := [room.position, room.position + Vector2(room.size.x, 0), room.end, room.position + Vector2(0, room.size.y)]
	var best: Vector2 = corners[0]
	for c in corners:
		if c.distance_to(player_pos) > best.distance_to(player_pos):
			best = c
	var s := seeker_scene.instantiate()
	s.position = best.lerp(room.get_center(), 0.15)
	s.add_to_group("seekers")
	add_child(s)


func _draw() -> void:
	if floor_texture:
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * floor_tile_scale)
		draw_texture_rect(floor_texture, Rect2(Vector2.ZERO, map_size / floor_tile_scale), true)
		draw_set_transform(Vector2.ZERO)
	else:
		draw_rect(Rect2(Vector2.ZERO, map_size), Color("1a1226"))
