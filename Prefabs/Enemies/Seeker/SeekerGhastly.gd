@tool
class_name SeekerGhastly
extends Seeker
## Variante Ghastly del Seeker. Depende de la luz del jugador (Flashlight, grupo "flashlight"):
## - Oscuro (fuera de la luz o luz apagada): persigue al jugador, acelerando (Seeker).
## - Llega al borde de la luz: se detiene, carga charge_time y se dispara en línea recta
##   hacia donde estaba el jugador (sin seguirlo, para que se pueda esquivar).
## - Si la luz se enciende con él adentro: retrocede hasta el borde y ahí carga.

enum State { CHASE, RETREAT, CHARGE, DASH }

## Segundos que se queda quieto cargando antes de dispararse.
@export var charge_time := 0.8
@export var dash_speed := 600.0
## Distancia que recorre el disparo antes de volver a perseguir.
@export var dash_distance := 450.0
## Velocidad al retroceder al borde de la luz.
@export var retreat_speed := 160.0
## Dónde carga, como fracción del radio de la luz externa (1 = borde exacto, que casi no
## se ve porque la luz se desvanece ahí; además la cámara puede no alcanzar a mostrarlo).
@export_range(0.1, 1.0) var edge_ratio := 0.75
## Tolerancia (px) para considerar que está en el borde.
@export var edge_margin := 12.0
## Temblor del Visual mientras carga.
@export var charge_shake := 3.0

var state := State.CHASE
var _charge_left := 0.0
var _dash_dir := Vector2.ZERO
var _dash_left := 0.0


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	var flashlight := get_tree().get_first_node_in_group("flashlight") as Flashlight
	var light := flashlight.active_light() if flashlight else null
	# "Iluminado" = dentro del ángulo del cono encendido; el alcance se mide con dist/radius.
	var lit := light != null and light.in_angle(global_position)
	var dist := light.global_position.distance_to(global_position) if light else INF
	var radius := light.range_px() * edge_ratio if light else 0.0

	match state:
		State.CHASE:
			speed += acceleration * delta
			global_position = global_position.move_toward(player.global_position, speed * delta)
			if lit and dist <= radius + edge_margin:
				state = State.RETREAT if dist < radius - edge_margin else State.CHARGE
				_charge_left = charge_time
		State.RETREAT:
			if not lit:
				state = State.CHASE
			else:
				var away := (global_position - light.global_position).normalized()
				global_position += away * retreat_speed * delta
				if dist >= radius:
					state = State.CHARGE
					_charge_left = charge_time
		State.CHARGE:
			if not lit:
				state = State.CHASE
			else:
				_charge_left -= delta
				if _charge_left <= 0:
					_dash_dir = global_position.direction_to(player.global_position)
					_dash_left = dash_distance
					state = State.DASH
		State.DASH:
			var step := minf(dash_speed * delta, _dash_left)
			global_position += _dash_dir * step
			_dash_left -= step
			if _dash_left <= 0:
				state = State.CHASE

	var visual := get_node_or_null("Visual") as Node2D
	if visual:
		visual.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * charge_shake if state == State.CHARGE else Vector2.ZERO
