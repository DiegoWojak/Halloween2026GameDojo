@tool
class_name Exit extends Area2D
## Salida del nivel (posición = esquina superior izquierda). El nivel la detecta por
## el grupo "exits": con la llave se escapa, sin ella avisa.

@export var size := Vector2(120, 40):
	set(v):
		size = v
		_rect.size = v
		_shape.position = v / 2
		queue_redraw()

var _rect := RectangleShape2D.new()
var _shape := CollisionShape2D.new()


func _ready() -> void:
	_shape.shape = _rect
	size = size
	add_child(_shape)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.2, 0.8, 0.3, 0.5))
