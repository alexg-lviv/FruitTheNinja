extends Area2D

const DAMAGE_COEFFICIENT = 0.1

@export var base_damage = 20
@export var speed = 500.0
var damage = base_damage + speed * DAMAGE_COEFFICIENT
var direction = Vector2.RIGHT
var size = 1.0
var is_dead = false

# For calculating trajectory based on elapsed time
var elapsed_time = 0

func _ready():
	size = $CollisionShape2D.shape.radius

func _process(delta):
	elapsed_time += delta

func _physics_process(delta):
	if (!is_dead):
		update_position(delta)
		handle_logic()
	handle_death()

func set_direction(dir: Vector2):
	direction = dir

func update_position(delta):
	position += direction * speed * delta

func handle_logic():
	pass

func handle_death():
	pass

func die():
	is_dead = true
