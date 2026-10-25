@tool
extends CharacterBody2D
class_name Jugador
## SOLO PRUEBA: jugador. Implementa el contrato que usan los enemigos:
## grupo "player", die(by) y hurt(by, push_to).
## --> Se mueve con move_* (flechas/WASD). `facing` (4 direcciones) lo usa la Flashlight hija.
## -->> Al morir muestra la pantalla del grupo "game_over" (GameOver.tscn);.

@export var speed := 200.0
@export var stun_time := 1.0
@export var push_speed := 700.0
## Golpes de Orbiter/Patrol que aguanta.
@export var max_health := 3
## Barra opcional (ProgressBar, TextureProgressBar...) que muestra la vida.
@export var health_bar: Range
## Pasos en loop mientras camina (bus Effects).
@export var footstep_sound: AudioStream = preload("res://MusicSfx/footsteps-player.wav")
## Golpe que quita vida (bus Effects).
@export var hit_sound: AudioStream = preload("res://MusicSfx/gettinghit.mp3")
## Al morir, en vez del golpe (bus Effects).
@export var die_sound: AudioStream = preload("res://MusicSfx/die_effect.mp3")

var health: int
var _steps := AudioStreamPlayer.new()
var _hit := AudioStreamPlayer.new()
var _stun_left := 0.0
var _push_to := Vector2.ZERO
var _mask := 1
## Hacia dónde mira. Con diagonal gana el eje horizontal (el de la animación lateral).
var facing := Vector2.RIGHT

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	health = max_health
	_steps.stream = footstep_sound
	_steps.bus = &"Effects"
	add_child(_steps)
	_hit.stream = hit_sound
	_hit.bus = &"Effects"
	_hit.process_mode = Node.PROCESS_MODE_ALWAYS # suena aunque el GameOver pause el juego
	add_child(_hit)
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health


## Muere al instante (Seeker). `by` = enemigo que lo mató, para la pantalla de muerte.
func die(by: Node2D = null) -> void:
	if _stun_left > 0:
		return # invulnerable durante el stun
	_hit.stream = die_sound
	_hit.play()
	var game_over := get_tree().get_first_node_in_group("game_over")
	if game_over:
		game_over.show_killer.call_deferred(by) # diferido: llega desde una señal de física
	else:
		get_tree().reload_current_scene.call_deferred()


## Quita 1 de vida y lo empuja a push_to (Orbiter, Patrol). Sin vida, muere.
func hurt(by: Node2D, push_to: Vector2) -> void:
	if _stun_left > 0:
		return
	health -= 1
	if health_bar:
		health_bar.value = health
	if health <= 0:
		die(by)
	else:
		_hit.play()
		stun(push_to)


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
	_animate()
	var walking := _stun_left <= 0 and velocity.length() > 1.0
	if walking != _steps.playing:
		_steps.playing = walking


## walk_side / walk_up / walk_down según facing. Quieto: idle de lado; mirando
## arriba/abajo queda en el primer frame de esa caminata (no hay idle vertical).
func _animate() -> void:
	var anim := &"walk_side"
	if facing.y < 0:
		anim = &"walk_up"
	elif facing.y > 0:
		anim = &"walk_down"
	_sprite.flip_h = facing.x < 0
	if velocity.length() > 1.0:
		_sprite.play(anim)
	elif anim == &"walk_side":
		_sprite.play(&"idle")
	else:
		_sprite.animation = anim
		_sprite.stop()
