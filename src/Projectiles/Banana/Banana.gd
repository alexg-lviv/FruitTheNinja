extends "res://src/Projectiles/Projectile.gd"

class_name Banana

const TIME_TO_RETURN = 2.0

const ROTATION_ACCELERATION = -10.0

var current_velocity = Vector2.ZERO

func _ready():
	super._ready()

func update_position(delta):
	current_velocity.x = speed * direction.x * clamp(TIME_TO_RETURN - elapsed_time, -1, 1)
	current_velocity.y = speed * direction.y * clamp(TIME_TO_RETURN - elapsed_time, -1, 1)

	position += current_velocity * delta
	rotation += ROTATION_ACCELERATION * delta

