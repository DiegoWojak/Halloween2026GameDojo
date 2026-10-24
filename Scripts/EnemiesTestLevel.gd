@tool
extends Node2D
 
## SOLO PRUEBA: mapa de idea1.png para probar enemigos.

@export_group("Seeker (desde cuartos)")
## Aparece al entrar a un cuarto, en la esquina más lejana al jugador.
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

@export_group("Piso")
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

@export_group("Paredes")
@export var wall_texture: Texture2D = preload("res://Art/Sprites/wall_up.png")
@export var broken_wall_texture: Texture2D = preload("res://Art/Sprites/broken_wall.png")
## Probabilidad por baldosa de empezar una zona rota (de 1 a 3 baldosas).
@export_range(0, 1) var broken_chance := 0.06
## Semilla del patrón de paredes rotas (mismo valor = mismo patrón).
@export var wall_seed := 1:
	set(v):
		wall_seed = v
		queue_redraw()
		
@export_group("Escenas")
@export var level2: PackedScene
@export var fade_screen: FadeScreen

const SIZE := Vector2(1000, 1100)
const WALL_TILE := 16.0
const WALLS := [
	# Exterior
	[Vector2(0, 0), Vector2(1000, 0)], [Vector2(0, 1100), Vector2(1000, 1100)],
	[Vector2(0, 0), Vector2(0, 1100)], [Vector2(1000, 0), Vector2(1000, 1100)],
	# Pasillo de la salida
	[Vector2(440, 0), Vector2(440, 300)], [Vector2(560, 0), Vector2(560, 300)],
	# Cuartos de arriba
	[Vector2(0, 300), Vector2(330, 300)], [Vector2(670, 300), Vector2(1000, 300)],
	# Pasillo central (con puertas)
	[Vector2(300, 300), Vector2(300, 400)], [Vector2(300, 500), Vector2(300, 650)], [Vector2(300, 750), Vector2(300, 850)],
	[Vector2(700, 300), Vector2(700, 400)], [Vector2(700, 500), Vector2(700, 650)], [Vector2(700, 750), Vector2(700, 850)],
	[Vector2(0, 550), Vector2(300, 550)], [Vector2(700, 550), Vector2(1000, 550)],
	# Fila de abajo y pasillo de la entrada
	[Vector2(0, 850), Vector2(420, 850)], [Vector2(540, 850), Vector2(1000, 850)],
	[Vector2(420, 850), Vector2(420, 950)], [Vector2(420, 1050), Vector2(420, 1100)],
	[Vector2(540, 850), Vector2(540, 950)], [Vector2(540, 1050), Vector2(540, 1100)],
]
const ROOMS := [
	Rect2(0, 0, 440, 300), Rect2(560, 0, 440, 300),
	Rect2(0, 300, 300, 250), Rect2(700, 300, 300, 250),
	Rect2(0, 550, 300, 300), Rect2(700, 550, 300, 300),
	Rect2(0, 850, 420, 250), Rect2(540, 850, 460, 250),
]
const EXIT_RECT := Rect2(440, 0, 120, 40)

var _has_key := false
var _current_room := -1
var _ghastly_timer := 0.0

@onready var _player: Node2D = $Player
@onready var _label: Label = $HUD/Label


func _ready() -> void:
	await fade_screen.fade_to_image()
	if Engine.is_editor_hint():
		return
	var body := StaticBody2D.new()
	# Rectángulos con grosor (no segmentos) para que el empujón del Patrol no atraviese paredes
	for w in WALLS:
		var rect := RectangleShape2D.new()
		rect.size = (w[1] - w[0]).abs() + Vector2(16, 16)
		var shape := CollisionShape2D.new()
		shape.shape = rect
		shape.position = (w[0] + w[1]) / 2
		body.add_child(shape)
	add_child(body)
	for key in get_tree().get_nodes_in_group("keys"):
		key.collected.connect(_on_key_collected)
	_label.text = "Busca la llave"


func _on_key_collected() -> void:
	_has_key = true
	_label.text = "¡Tienes la llave! Ve a la salida"


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var p := _player.position
	if EXIT_RECT.has_point(p):
		if _has_key:
			_label.text = "¡Escapaste!"
			await fade_screen.fade_to_black()
			get_tree().change_scene_to_packed(level2)
			#aca instatizo nivel
		else:
			_label.text = "Necesitas la llave"
	var room := _room_at(p)
	if room != _current_room:
		_current_room = room
		if room != -1 and get_tree().get_nodes_in_group("seekers").size() < max_seekers:
			_spawn_seeker(ROOMS[room], p)
	if ghastly_interval > 0:
		_ghastly_timer += delta
		if _ghastly_timer >= ghastly_interval:
			_ghastly_timer = 0.0
			if get_tree().get_nodes_in_group("ghastly").size() < max_ghastly:
				_spawn_ghastly(p)


func _spawn_ghastly(player_pos: Vector2) -> void:
	var pos := player_pos
	for i in 20: # ponytail: muestreo al azar; si el mapa es chico puede quedar más cerca que ghastly_min_distance
		pos = Vector2(randf() * SIZE.x, randf() * SIZE.y)
		if pos.distance_to(player_pos) >= ghastly_min_distance:
			break
	var g := ghastly_scene.instantiate()
	g.position = pos
	g.add_to_group("ghastly")
	add_child(g)


func _room_at(p: Vector2) -> int:
	for i in ROOMS.size():
		if ROOMS[i].has_point(p):
			return i
	return -1


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
		draw_texture_rect(floor_texture, Rect2(Vector2.ZERO, SIZE / floor_tile_scale), true)
		draw_set_transform(Vector2.ZERO)
	else:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color("1a1226"))
	draw_rect(EXIT_RECT, Color(0.2, 0.8, 0.3, 0.5))
	# Baldosas de WALL_TILE a lo largo de cada pared (mismo grosor que la colisión).
	var rng := RandomNumberGenerator.new()
	rng.seed = wall_seed
	var broken_left := 0
	for w in WALLS:
		var r := Rect2(w[0].min(w[1]), (w[1] - w[0]).abs()).grow(WALL_TILE / 2)
		var horizontal := r.size.x > r.size.y
		var length := r.size.x if horizontal else r.size.y
		var step := Vector2(WALL_TILE, 0) if horizontal else Vector2(0, WALL_TILE)
		for i in ceili(length / WALL_TILE):
			if broken_left == 0 and rng.randf() < broken_chance:
				broken_left = rng.randi_range(1, 3)
			var tex := wall_texture
			if broken_left > 0:
				tex = broken_wall_texture
				broken_left -= 1
			# La última baldosa se recorta para no salirse de la pared
			var cut := minf(WALL_TILE, length - i * WALL_TILE)
			var size := Vector2(cut, WALL_TILE) if horizontal else Vector2(WALL_TILE, cut)
			draw_texture_rect_region(tex, Rect2(r.position + step * i, size), Rect2(Vector2.ZERO, size))
