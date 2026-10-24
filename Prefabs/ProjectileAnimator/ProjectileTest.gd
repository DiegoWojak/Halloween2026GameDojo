class_name ProjectileTest extends Node2D

@export var origin: Node2D
@export var node: Node2D
@export var target: Node2D

func _ready() -> void:
	var start: Vector2 = node.position
	var end: Vector2 = Vector2(1000, 1000)
	origin.position = start
	target.position = end
	ProjectileAnimator.animate_projectile(node, start, end, 500)
	# ProjectileAnimator.animate_projectile(self, self.position, Vector2(-500, -500), 600)
