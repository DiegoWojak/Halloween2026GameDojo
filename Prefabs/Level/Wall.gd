@tool
class_name Wall extends StaticBody2D
## Pared arrastrable. La posición es la esquina superior izquierda; la textura se
## repite hasta llenar `size` y la colisión sigue a `size`.

@export var texture: Texture2D:
	set(v):
		texture = v
		queue_redraw()
@export var size := Vector2(64, 64):
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
	add_child(_shape) # sin owner: no se guarda en la escena


func _draw() -> void:
	if texture:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), true)
