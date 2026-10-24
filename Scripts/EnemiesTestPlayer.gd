@tool
extends CharacterBody2D
class_name Jugador
## SOLO PRUEBA: jugador. Implementa el contrato que usan los enemigos:
## grupo "player", die() y stun(push_to).
## Se mueve con move_* (flechas/WASD). `facing` (4 direcciones) lo usa la Flashlight hija.

@export var speed := 200.0
@export var stun_time := 1.0
@export var push_speed := 700.0

var _stun_left := 0.0
var _push_to := Vector2.ZERO
var _mask := 1
## Hacia dónde mira. Con diagonal gana el eje horizontal (el de la animación lateral).
var facing := Vector2.RIGHT

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func die() -> void:
	if _stun_left > 0:
		return # invulnerable durante el stun
	get_tree().reload_current_scene.call_deferred()


## Sin control durante stun_time; mientras tanto es empujado hacia push_to (global),
## atravesando paredes para no quedar atrapado contra ellas.
func stun(push_to: Vector2) -> void:
	if _stun_left <= 0:
		_mask = collision_mask
	collision_mask = 0
	_stun_left = stun_time
	_push_to = push_to


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _stun_left > 0:
		_stun_left -= delta
		if _stun_left <= 0:
			collision_mask = _mask
		modulate = Color(0.4, 0.7, 1, 0.5 + 0.5 * sin(_stun_left * 40)) if _stun_left > 0 else Color.WHITE
		velocity = (_push_to - global_position).limit_length(push_speed * delta) / delta
	else:
		var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = input * speed
		if input.x != 0:
			facing = Vector2(signf(input.x), 0)
		elif input.y != 0:
			facing = Vector2(0, signf(input.y))
	move_and_slide()
	# ponytail: arriba/abajo usan walk_side hasta que llegue player_horizontal_mov.png
	if facing.x != 0:
		_sprite.flip_h = facing.x < 0
	_sprite.play(&"walk_side" if velocity.length() > 1.0 else &"idle")
