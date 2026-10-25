@tool
class_name Patrol
extends CharacterBody2D
## Enemigo Patrol (cuadrado).
## Patrulla entre point_a y point_b (relativos a su posición inicial).
## Si el jugador entra a `room`, lo persigue. Al tocarlo le quita 1 de vida y lo empuja a `exit_point`.
##
## Contrato con el jugador: nodo en el grupo "player" con método hurt(by, push_to).

## Zona que vigila, en coordenadas globales. Vacía = nunca persigue.
@export var room := Rect2():
	set(v):
		room = v
		queue_redraw()
## Punto global al que empuja al jugador (normalmente justo afuera de la puerta).
## Vector2.ZERO = lo aleja push_distance en dirección opuesta al Patrol.
@export var exit_point := Vector2.ZERO:
	set(v):
		exit_point = v
		queue_redraw()
@export var push_distance := 150.0
@export var point_a := Vector2.ZERO
@export var point_b := Vector2(150, 0)
@export var patrol_speed := 80.0
@export var chase_speed := 140.0

var _origin: Vector2
var _going_to_b := true


func _ready() -> void:
	_origin = global_position
	set_notify_transform(true)
	if Engine.is_editor_hint():
		return
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var target: Vector2
	var speed := patrol_speed
	if player and room.has_point(player.global_position):
		target = player.global_position
		speed = chase_speed
	else:
		target = _origin + (point_b if _going_to_b else point_a)
		if global_position.distance_to(target) < 4:
			_going_to_b = not _going_to_b
	velocity = global_position.direction_to(target) * speed
	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not body.has_method("hurt"):
		return
	var push_to := exit_point
	if push_to == Vector2.ZERO:
		push_to = body.global_position + global_position.direction_to(body.global_position) * push_distance
	body.hurt(self, push_to)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	# Ayudas visuales solo en el editor: zona vigilada, ruta y punto de empuje
	draw_rect(Rect2(room.position - global_position, room.size), Color(1, 0, 0, 0.5), false, 2)
	draw_line(point_a, point_b, Color(1, 0.6, 0.6, 0.6), 2)
	if exit_point != Vector2.ZERO:
		draw_circle(exit_point - global_position, 6, Color.ORANGE)
