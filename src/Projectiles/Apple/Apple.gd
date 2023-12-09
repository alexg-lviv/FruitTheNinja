extends "res://src/Projectiles/Projectile.gd"

class_name Apple

func get_p_name():
	return "Apple"

func _ready():
	super._ready()
	color = Color(1, 0, 0)
