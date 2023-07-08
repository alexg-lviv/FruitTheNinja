extends Area2D

const DAMAGE_COEFFICIENT = 0.1

@export var rotation_speed = 5
@export var base_damage = 20
@export var speed = 500.0
var damage = base_damage + speed * DAMAGE_COEFFICIENT
var direction = Vector2.RIGHT
var size = 1.0
var is_dead = false
var is_finished_dying: bool = false;
var on_field = false
var bounce_count = 0

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var DeathTimer: Timer = get_node("DeathTimer")
#@onready var FieldArea: Area2D = get_tree().get_current_scene().get_node("FieldArea")

# For calculating trajectory based on elapsed time
var elapsed_time = 0

func _ready():
	size = $CollisionShape2D.shape.radius
#	if FieldArea != null:
#		FieldArea.connect("body_entered", _on_field_area_area_entered)

func _process(delta):
	elapsed_time += delta

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
	rotation += rotation_speed * delta

func handle_logic():
	if bounce_count >= 1:
		die()

func handle_death():
	pass

func die():
	is_dead = true
	AnimPlayer.play("simple_death")
	DeathTimer.start()

func _on_death_timer_timeout():
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area: Area2D):
	if area.name == "FieldArea":
		on_field = true
	if on_field and area.name != "FieldArea":
		bounce_count += 1
