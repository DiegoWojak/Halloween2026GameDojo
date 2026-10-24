# a class that moves a 2D node imitating a projectile trajectory
class_name ProjectileAnimator

static func animate_projectile(node: Node2D, from: Vector2, to: Vector2, height_max: float, gravity: float = 2500) -> void:
	var dist_x: float = absf(to.x - from.x)
	var zenit_y: float = minf(from.y, to.y) - height_max
	var dist_ascent: float = from.y - zenit_y
	var dist_drop: float = to.y - zenit_y

	var t_up: float = sqrt(2.0 * absf(dist_ascent) / gravity)
	var t_down: float = sqrt(2.0 * absf(dist_drop) / gravity)
	var t_total: float = t_up + t_down

	var vy0: float = gravity * t_up
	# var vyf: float = dist_drop / t_down
 
	var time_current: float = 0
	var vy: float = vy0
	while node.position != to:
		node.position.x = move_toward(node.position.x, to.x, dist_x / t_total * node.get_process_delta_time())
		if time_current < t_up:
			node.position.y = move_toward(node.position.y, zenit_y, (vy) * node.get_process_delta_time())
			vy -= gravity * node.get_process_delta_time()
		else:
			node.position.y = move_toward(node.position.y, to.y, vy * node.get_process_delta_time())
			vy += gravity * node.get_process_delta_time()
			# print(vy)
		await node.get_tree().process_frame
		time_current += node.get_process_delta_time()
		print(node.position)
	node.position = to

	pass

static func abort(node: Node) -> void:
	#TODO send a signal and listen for it in the while loop
	pass
