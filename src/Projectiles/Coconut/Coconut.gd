extends "res://src/Projectiles/Projectile.gd"

func _ready():
	super._ready()


func update_position(delta):
	super.update_position(delta)
	rotation += 5 * delta
