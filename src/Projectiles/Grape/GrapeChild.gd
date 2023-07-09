extends "res://src/Projectiles/Projectile.gd"

var rng = RandomNumberGenerator.new()

func _ready():
	super._ready()
	color = Color(0.445, 0.195, 0.750)
	$DieTimer.wait_time = rng.randf_range(0.7, 1.4);
	$DieTimer.start()


func _on_die_timer_timeout():
	Signals.emit_signal("camera_shake_requested", size / 1.5, 0.3)
	crash()

func slice():
	pass
