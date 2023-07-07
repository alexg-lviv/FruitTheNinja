extends "res://src/Projectiles/Projectile.gd"

const TIME_TO_RETURN = 2.0

var angle = 0
var rotation_acceleration = -10.0

var current_velocity = Vector2.ZERO

func _ready():
	super._ready()
	angle = atan2(direction.y, direction.x)

func update_position(delta):
	current_velocity.x = speed * cos(angle) * clamp(TIME_TO_RETURN - elapsed_time, -1, 1)
	current_velocity.y = speed * sin(angle) * clamp(TIME_TO_RETURN - elapsed_time, -1, 1)

	position += current_velocity * delta
	rotation += rotation_acceleration * delta

