@tool
class_name Orbiter
extends Area2D
## Enemigo Orbiter (rombo). Se mueve izquierda-derecha (LINE) o en círculo (CIRCLE)
## alrededor de su posición inicial.
##
## Contrato con el jugador: nodo en el grupo "player" con método die().

enum Mode { LINE, CIRCLE }

@export var mode := Mode.LINE
@export var radius := 100.0
@export var speed := 2.0 ## radianes/seg

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
	if body.is_in_group("player") and body.has_method("die"):
		body.die()


func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(0, -16), Vector2(12, 0), Vector2(0, 16), Vector2(-12, 0)]), Color.CYAN)
