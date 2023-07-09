extends Line2D

const MAX_POINTS: int = 200


func update_trajectory(
		dir: Vector2,
		speed: float,
		size: float,
		power: float,
		delta: float,
		gravity: float = 0.0,
		bouncing: bool = false,
		color: Vector3 = Vector3(1.0, 1.0, 1.0)
		):
	clear_points()
	width = size
	var mat = get_material()
	mat.set_shader_parameter("color", color)
	mat.set_shader_parameter("speed", power * 10)
	
	var point_pos: Vector2 = global_position
	# Some shit with velocity maybe
	add_point(point_pos);
	point_pos += dir * 1000
	add_point(point_pos);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	show()

