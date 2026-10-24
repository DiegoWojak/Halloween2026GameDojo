@tool
extends CharacterBody2D
## SOLO PRUEBA: jugador placeholder (círculo). Implementa el contrato que usan los enemigos:
## grupo "player", die() y stun(push_to).

@export var speed := 200.0
@export var stun_time := 1.0
@export var push_speed := 700.0

var _stun_left := 0.0
var _push_to := Vector2.ZERO


func die() -> void:
	if _stun_left > 0:
		return # invulnerable durante el stun
	get_tree().reload_current_scene.call_deferred()


## Sin control durante stun_time; mientras tanto es empujado hacia push_to (global).
func stun(push_to: Vector2) -> void:
	_stun_left = stun_time
	_push_to = push_to


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _stun_left > 0:
		_stun_left -= delta
		modulate = Color(0.4, 0.7, 1, 0.5 + 0.5 * sin(_stun_left * 40)) if _stun_left > 0 else Color.WHITE
		velocity = (_push_to - global_position).limit_length(push_speed * delta) / delta
	else:
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
	move_and_slide()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 14, Color.WHITE)
