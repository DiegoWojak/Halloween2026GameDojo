@tool
class_name Floor extends Node2D
## Piso arrastrable (posición = esquina superior izquierda). Repite `texture` hasta llenar `size`.
## Posiciones en múltiplos de 16 * tile_scale para que las baldosas calcen entre pisos.

@export var texture: Texture2D = preload("res://Art/Sprites/tile_floor.png"):
	set(v):
		texture = v
		queue_redraw()
@export var size := Vector2(128, 128):
	set(v):
		size = v
		queue_redraw()
@export var tile_scale := 2.0:
	set(v):
		tile_scale = v
		queue_redraw()


func _draw() -> void:
	if texture:
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * tile_scale)
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size / tile_scale), true)
