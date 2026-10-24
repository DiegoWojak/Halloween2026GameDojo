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


@export_group("Escenas")
@export var fade_screen: FadeScreen
@export var menu: PackedScene

const EXIT_RECT := Rect2(440, 0, 120, 40)

var _has_key := false


@onready var _player: Node2D = $Player
@onready var _label: Label = $HUD/Label


func _ready() -> void:
	await fade_screen.fade_to_image()
	if Engine.is_editor_hint():
		return
	var body := StaticBody2D.new()
	# Rectángulos con grosor (no segmentos) para que el empujón del Patrol no atraviese paredes

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
			get_tree().paused = true
			#aca instatizo nivel
		else:
			_label.text = "Necesitas la llave"
	

		
	
				








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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Jugador and _has_key:
		await fade_screen.fade_to_black()
		get_tree().change_scene_to_packed(menu)
