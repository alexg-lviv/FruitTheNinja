extends "res://src/Projectiles/Projectile.gd"

class_name Pineapple

var current_speed = 0

var time_til_mach10 = 0.7

func _ready():
	super._ready()
	color = Color(0.837, 1.00, 0.0200)
	Signals.emit_signal("camera_shake_requested", 1.5, time_til_mach10 * 8)
	$LaunchSound.play()

func update_position(delta):
	position += direction * current_speed * delta

func update_rotation(delta):
	MainSprite.rotation = direction.angle() + deg_to_rad(-90)
	$Sprite2D/TrailParticles.rotation = direction.angle() + deg_to_rad(-90)

func handle_logic():
	damage = base_damage + current_speed * DAMAGE_COEFFICIENT
	if elapsed_time < time_til_mach10:
		current_speed += 3
	else:
		current_speed += 30
	
	current_speed = min(speed, current_speed)

func die(play_sound=true):
	super.die(false)
	$Sprite2D/TrailParticles.emitting = false
	Signals.emit_signal("camera_shake_requested", 10.0, 0.7)


func slice():
	if is_dead:
		return
	$SplitPieces.visible = true
	$SliceAnimationPlayer.play("split")
	$HitPlayer.play()
	die()

func crash():
	if is_dead:
		return
	AnimPlayer.play("simple_death")
	$DeathSound.play()
	die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	crash()
