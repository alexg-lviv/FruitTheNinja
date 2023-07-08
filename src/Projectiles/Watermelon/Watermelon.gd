extends "res://src/Projectiles/Projectile.gd"

class_name Watermelon

func _ready():
	super._ready()

func update_position(delta):
	super.update_position(delta)
	rotation += 10 * delta
