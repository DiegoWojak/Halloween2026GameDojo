@tool
class_name Door extends Wall
## Puerta que abre/cierra un Lever.
## Cerrada: con luz normal parece pared; con luz UV se ve en su `color` (pasable con interruptor).
## Abierta: no se ve con ninguna luz y no tiene colisión.

@export var open := false:
	set(v):
		open = v
		_shape.set_deferred("disabled", v)
		_redraw()
## Color con que la revela la luz UV (el de su Lever).
@export var color := Color.WHITE:
	set(v):
		color = v
		_redraw()
## Capa de luz que solo ilumina la luz UV (light_secret de la Flashlight).
@export_flags_2d_render var uv_light_mask := 2

@onready var _uv_look: Node2D = $UVLook


func _ready() -> void:
	super()
	_uv_look.draw.connect(_draw_uv_look)
	if not Engine.is_editor_hint(): # en el editor se ve siempre, para diseñar
		var mat := CanvasItemMaterial.new()
		mat.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
		_uv_look.material = mat
		_uv_look.light_mask = uv_light_mask


func _redraw() -> void:
	queue_redraw()
	if is_node_ready():
		_uv_look.queue_redraw()


## Aspecto de pared (luz normal).
func _draw() -> void:
	if open:
		if Engine.is_editor_hint():
			draw_rect(Rect2(Vector2.ZERO, size), color, false, 1)
		return
	if texture:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), true)


## Aspecto con luz UV: relleno de color, borde punteado e interruptor al centro.
func _draw_uv_look() -> void:
	if open:
		return
	var r := Rect2(Vector2.ZERO, size)
	_uv_look.draw_rect(r, Color(color, 0.55))
	var corners := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	for i in 4:
		_uv_look.draw_dashed_line(corners[i], corners[(i + 1) % 4], color.lightened(0.4), 2, 6)
	_uv_look.draw_rect(Rect2(r.get_center() - Vector2(5, 5), Vector2(10, 10)), color.lightened(0.6))
