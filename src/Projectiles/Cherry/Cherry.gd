extends "res://src/Projectiles/Projectile.gd"

class_name Cherry

const MAX_EXPLOSION_INCREASE = 3

var exploding = false
var explosion_frame_counter = 0

func _ready():
	super._ready()
	$DetonateAnimationPlayer.play("detonating")
	color = Color("#d51e5a")

func crash():
	$DetonateAnimationPlayer.stop()
	super.crash()

func slice():
	super.slice()
	$DetonateAnimationPlayer.stop()

func update_position(delta):
	if !exploding:
		super.update_position(delta)
	
func handle_logic():
	super.handle_logic()
	if !exploding && elapsed_time > 1:
		exploding = true
		explode()
	if exploding:
		explosion_frame_counter += 1
	
	if explosion_frame_counter > 1:
		crash()

func explode():
	$CollisionShape2D.shape.radius = 150
	$ExplosionParticles.restart()
	$ExplosionSound.play()
	damage = 50
	Signals.emit_signal("camera_shake_requested", 50, 0.2)
