extends "res://src/Projectiles/Projectile.gd"

class_name Coconut

func get_p_name():
	return "Coconut"

func _ready():
	super._ready()
	color = Color(0.960, 0.960, 0.960)


func update_position(delta):
	super.update_position(delta)
