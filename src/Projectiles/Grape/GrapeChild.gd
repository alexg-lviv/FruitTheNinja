extends "res://src/Projectiles/Projectile.gd"

func _ready():
	super._ready()
	print(size)
	color = Color(0.445, 0.195, 0.750)


func _on_die_timer_timeout():
	die()
