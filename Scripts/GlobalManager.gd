# class_name GlobalManager
extends Node

var secret_items: Array[Node]

func _ready() -> void:
	secret_items = get_tree().get_nodes_in_group("secret")
	secret_toggle_visibility(false)

func secret_toggle_visibility(value: bool) -> void:
	for item: Node in secret_items:
		var canvas_item: CanvasItem = (item as CanvasItem)
		if canvas_item:
			canvas_item.visible = value