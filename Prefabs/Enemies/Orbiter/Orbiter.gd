@tool
class_name Orbiter
extends Area2D
## Enemigo Orbiter (gato, enemy_type1.png). Se mueve izquierda-derecha (LINE) o en círculo (CIRCLE)
## alrededor de su posición inicial. Al tocar al jugador le quita 1 de vida y lo
## empuja afuera del cuarto (`exit_point`).
##
## Contrato con el jugador: nodo en el grupo "player" con método hurt(by, push_to).

enum Mode { LINE, CIRCLE }

@export var mode := Mode.LINE
@export var radius := 100.0
@export var speed := 2.0 ## radianes/seg
## Punto global al que empuja al jugador (normalmente justo afuera de la puerta del cuarto).
## Vector2.ZERO = lo aleja push_distance en dirección opuesta al Orbiter.
@export var exit_point := Vector2.ZERO:
	set(v):
		exit_point = v
		queue_redraw()
@export var push_distance := 150.0

var _origin: Vector2
var _t := 0.0


func _ready() -> void:
	_origin = position
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_t += delta * speed
	if mode == Mode.LINE:
		position = _origin + Vector2(sin(_t) * radius, 0)
	else:
		position = _origin + Vector2(cos(_t), sin(_t)) * radius


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not body.has_method("hurt"):
		return
	var push_to := exit_point
	if push_to == Vector2.ZERO:
		push_to = body.global_position + global_position.direction_to(body.global_position) * push_distance
	body.hurt(self, push_to)


func _draw() -> void:
	if Engine.is_editor_hint() and exit_point != Vector2.ZERO:
		draw_circle(exit_point - global_position, 6, Color.ORANGE)
