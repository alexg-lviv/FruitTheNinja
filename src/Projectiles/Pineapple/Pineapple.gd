extends "res://src/Projectiles/Projectile.gd"

var current_speed = 0

func _ready():
	super._ready()
	rotation = direction.angle() + deg_to_rad(-90)

func update_position(delta):
	position += direction * current_speed * delta

func handle_logic():
	damage = base_damage + current_speed * DAMAGE_COEFFICIENT
	if elapsed_time < 0.7:
		current_speed += 3
	else:
		current_speed += 30
	
	current_speed = min(speed, current_speed)
