@tool
class_name Room extends Node2D
## Zona de un cuarto (posición = esquina superior izquierda). Al entrar el jugador
## puede aparecer un Seeker en la esquina más lejana. Solo se ve en el editor.

@export var size := Vector2(300, 250):
	set(v):
		size = v
		queue_redraw()


func rect() -> Rect2:
	return Rect2(global_position, size)


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.6, 1, 0.15))
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.6, 1), false, 2)
