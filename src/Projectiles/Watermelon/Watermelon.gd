extends "res://src/Projectiles/Projectile.gd"

class_name Watermelon

var bounce_count = 0

func _ready():
	super._ready()

func handle_logic():
	if bounce_count >= 5:
		die()

func _on_area_entered(area: Area2D):
	if on_field:
		match area.name:
			"Top", "Bottom":
				direction.y *= -1
			"Left", "Right":
				direction.x *= -1
				rotation_speed *= -1
		bounce_count += 1

