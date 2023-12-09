extends "res://src/Projectiles/Projectile.gd"

class_name Watermelon

const MAX_BOUNCE_COUNT = 5

@onready var CrashParticles = $CrashParticles

func get_p_name():
	return "Watermelon"

func _ready():
	super._ready()
	CrashParticles.emitting = false
	color = Color(0.990, 0.109, 0.138)

func handle_logic():
	if bounce_count >= MAX_BOUNCE_COUNT:
		$DeathSound.play()
		crash()

func _on_area_entered(area: Area2D):
	super._on_area_entered(area)
	
	if on_field:
		match area.name:
			"Top", "Bottom":
				$HitPlayer.play()
				Signals.emit_signal("camera_shake_requested", 12.0, 0.5)
				DecalSystem.add_decal(global_position, color, size)
				direction.y *= -1
				if bounce_count < MAX_BOUNCE_COUNT:
					CrashParticles.restart()
			"Left", "Right":
				$HitPlayer.play()				
				Signals.emit_signal("camera_shake_requested", 12.0, 0.5)
				DecalSystem.add_decal(global_position, color, size)
				direction.x *= -1
				rotation_speed *= -1
				if bounce_count < MAX_BOUNCE_COUNT:
					CrashParticles.restart()
