class_name FadeScreen extends Node

@export var fade_node: CanvasItem

@export var duration: float = 1

signal signal_black
signal signal_image

func _ready() -> void:
	set_visible(true)
	fade_node.modulate.a = 1

func fade_to_black() -> void:
	fade_node.modulate.a = 0
	set_visible(true)
	await create_tween().tween_property(fade_node, "modulate:a", 1, duration).finished
	signal_black.emit()

func fade_to_image() -> void:
	fade_node.modulate.a = 1
	await create_tween().tween_property(fade_node, "modulate:a", 0, duration).finished
	set_visible(false)
	signal_image.emit()

func set_visible(value: bool) -> void:
	fade_node.visible = value
