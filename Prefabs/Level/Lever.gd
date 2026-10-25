@tool
class_name Lever extends Area2D
## Palanca de piso: al pararse encima abre las puertas de `opens` y cierra las de `closes`.
## Solo la revela la luz UV.
## Palancas excluyentes (rojo/azul): cada una cierra las puertas de la otra.
## En el editor dibuja líneas a sus puertas (continua = abre, punteada = cierra).

const SIZE := Vector2(28, 28)

@export var color := Color.RED:
	set(v):
		color = v
		queue_redraw()
@export var opens: Array[Door] = []
@export var closes: Array[Door] = []
## Capa de luz que solo ilumina la luz UV: la palanca no se ve con la luz normal.
@export_flags_2d_render var uv_light_mask := 2


func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	var shape := CollisionShape2D.new()
	shape.shape = rect
	add_child(shape) # sin owner: no se guarda en la escena
	if Engine.is_editor_hint(): # en el editor se ve siempre, para diseñar
		return
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
	material = mat
	light_mask = uv_light_mask
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	for door in opens:
		door.open = true
	for door in closes:
		door.open = false
	get_tree().call_group("levers", "queue_redraw")


## Encendida = todas sus puertas de `opens` están abiertas.
func is_on() -> bool:
	return not opens.is_empty() and opens.all(func(d: Door) -> bool: return d and d.open)


func _draw() -> void:
	var r := Rect2(-SIZE / 2, SIZE)
	draw_rect(r, color.darkened(0.6))
	draw_rect(r.grow(-6), color.lightened(0.4) if is_on() else color.darkened(0.2))
	if not Engine.is_editor_hint():
		return
	for door in opens:
		if door:
			draw_line(Vector2.ZERO, to_local(door.global_position + door.size / 2), color, 2)
	for door in closes:
		if door:
			draw_dashed_line(Vector2.ZERO, to_local(door.global_position + door.size / 2), color.darkened(0.3), 2, 10)
