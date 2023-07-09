extends Area2D

const DAMAGE_COEFFICIENT = 0.1

@export var rotation_speed = 5
@export var base_damage = 20
@export var speed = 500.0
var damage = base_damage + speed * DAMAGE_COEFFICIENT
var direction = Vector2.RIGHT
var size = 1.0
var is_dead = false
var color: Color = Color(1, 1, 1)
var is_finished_dying: bool = false;
var on_field = false
var bounce_count = 0

@onready var MainSprite: Sprite2D = get_node("Sprite2D")
@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var DeathTimer: Timer = get_node("DeathTimer")

var animation_list

# For calculating trajectory based on elapsed time
var elapsed_time = 0

func _ready():
	size = $CollisionShape2D.shape.radius
	$DeathParticles.emitting = false
#	$DeathTimer.wait_time = $DeathParticles.lifetime
	$SplitPieces.visible = false
	animation_list = $SliceAnimationPlayer.get_animation_list()
	animation_list.remove_at(0)

func _process(delta):
	elapsed_time += delta
	damage = base_damage + speed * DAMAGE_COEFFICIENT

func _physics_process(delta):
	if (!is_dead):
		update_position(delta)
		update_rotation(delta)
		handle_logic()
	handle_death()

func set_direction(dir: Vector2):
	direction = dir

func update_position(delta):
	position += direction * speed * delta
	
func update_rotation(delta):
	MainSprite.rotation += rotation_speed * delta

func handle_logic():
	if bounce_count >= 1 and !is_dead:
		$HitPlayer.play()
		Signals.emit_signal("camera_shake_requested", size / 1.5, 0.3)
		crash()

func handle_death():
	pass

func die(play_sound=true):
	if is_dead:
		return
	
	set_physics_process(false) 
	
	is_dead = true
	DeathTimer.start()
	if play_sound:
		$DeathSound.play()
	$DeathParticles.restart()
	DecalSystem.add_decals(global_position, color, size)

func slice():
	if is_dead:
		return
	$SplitPieces.visible = true
	var random_animation = animation_list[randi() % animation_list.size()]
	$SliceAnimationPlayer.play(random_animation)
	die()

func crash():
	if is_dead:
		return
	AnimPlayer.play("simple_death")
	die()

func _on_death_timer_timeout():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area: Area2D):
	if area.name == "FieldArea":
		on_field = true
	if on_field and area.name != "FieldArea":
		bounce_count += 1
