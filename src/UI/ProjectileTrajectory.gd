extends Line2D

const MAX_POINTS: int = 200

func _ready():
	update_trajectory(Vector2(1, 1).normalized(), 10, 10, 0.5, 0)


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
	mat.set_shader_parameter("speed", power * 10)
	mat.set_shader_parameter("color", color)
	
	var point_pos: Vector2 = global_position
	
	for i in MAX_POINTS:
		var velocity: Vector2 = dir * speed;
		
		# Some shit with velocity maybe
		
		point_pos += velocity * delta
		
		add_point(point_pos);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	show()
	update_trajectory(Vector2(1, 1).normalized(), 500, 10, 0.5, delta)
