@tool
class_name Seeker
extends Area2D
## Enemigo Seeker (triángulo). Va lento hacia el jugador atravesando paredes
## y desaparece tras `lifetime` segundos. Lo instancia el nivel (p. ej. al entrar a un cuarto).
## El visual vive en la escena (variantes: Seeker.tscn = triángulo, SeekerGhastly.tscn = fantasma).
##
## Contrato con el jugador: nodo en el grupo "player" con método die().

@export var speed := 40.0
## Cuánto sube speed por segundo (aumento lineal). 0 = velocidad constante.
@export var acceleration := 0.0
## Segundos antes de desaparecer. 0 = no desaparece.
@export var lifetime := 8.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	if lifetime > 0:
		get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	speed += acceleration * delta
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		global_position = global_position.move_toward(player.global_position, speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()
