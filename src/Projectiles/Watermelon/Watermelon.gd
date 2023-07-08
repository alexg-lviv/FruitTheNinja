extends "res://src/Projectiles/Projectile.gd"

class_name Watermelon

const MAX_BOUNCE_COUNT = 5

@onready var CrashParticles = $CrashParticles

func _ready():
	super._ready()
	CrashParticles.emitting = false
	color = Color(0.990, 0.109, 0.138)

func handle_logic():
	if bounce_count >= MAX_BOUNCE_COUNT:
		die()

func _on_area_entered(area: Area2D):
	super._on_area_entered(area)
	
	if on_field:
		match area.name:
			"Top", "Bottom":
				Signals.emit_signal("camera_shake_requested", 12.0, 0.5)
				direction.y *= -1
				if bounce_count < MAX_BOUNCE_COUNT:
					CrashParticles.restart()
			"Left", "Right":
				Signals.emit_signal("camera_shake_requested", 12.0, 0.5)
				direction.x *= -1
				rotation_speed *= -1
				if bounce_count < MAX_BOUNCE_COUNT:
					CrashParticles.restart()
