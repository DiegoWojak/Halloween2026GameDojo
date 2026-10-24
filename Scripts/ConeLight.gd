@tool
class_name ConeLight
extends PointLight2D
## PointLight2D con forma de cono (linterna). Genera su propia textura con el ángulo de
## cada píxel: dentro de cone_angle ilumina, fuera queda oscuro. El vértice está en el nodo
## y apunta a +X (rotar el nodo o su padre para apuntar). El alcance se ajusta con
## texture_scale, como en cualquier PointLight2D. Se ve en vivo en el editor.

## Apertura total del cono, en grados.
@export_range(1.0, 360.0) var cone_angle := 60.0:
	set(v):
		cone_angle = v
		_rebuild()
## Suavizado del borde lateral (fracción de la mitad del ángulo).
@export_range(0.0, 1.0) var softness := 0.35:
	set(v):
		softness = v
		_rebuild()
## Luz alrededor del vértice en todas direcciones (fracción del alcance). 0 = nada.
@export_range(0.0, 1.0) var near_radius := 0.1:
	set(v):
		near_radius = v
		_rebuild()
## Resolución de la textura generada (px). El alcance en pantalla no cambia.
@export var size := 256:
	set(v):
		size = maxi(v, 8)
		_rebuild()


func _ready() -> void:
	_rebuild()


## La textura se genera; no se guarda en la escena.
func _validate_property(property: Dictionary) -> void:
	if property.name == "texture":
		property.usage &= ~PROPERTY_USAGE_STORAGE


func _rebuild() -> void:
	if not is_node_ready():
		return
	var img := Image.create(size, size, false, Image.FORMAT_L8)
	var c := size / 2.0
	var half := deg_to_rad(cone_angle) / 2.0
	var soft := half * softness
	for y in size:
		for x in size:
			var d := Vector2(x + 0.5 - c, y + 0.5 - c)
			var r := d.length() / c
			var cone := (1.0 - smoothstep(half - soft, half, absf(d.angle()))) * (1.0 - smoothstep(0.7, 1.0, r))
			var near := 1.0 - smoothstep(near_radius * 0.5, near_radius, r) if near_radius > 0.0 else 0.0
			var v := maxf(cone, near)
			img.set_pixel(x, y, Color(v, v, v))
	texture = ImageTexture.create_from_image(img)


## Alcance en px de mundo (radio de la textura escalado).
func range_px() -> float:
	return size * 0.5 * texture_scale * global_scale.x


## true si p (global) está dentro del ángulo del cono (sin mirar el alcance).
func in_angle(p: Vector2) -> bool:
	return absf(angle_difference(global_rotation, (p - global_position).angle())) <= deg_to_rad(cone_angle) / 2.0
