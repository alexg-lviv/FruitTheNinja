extends Area2D

const DAMAGE_COEFFICIENT = 0.1

@export var speed = 5.0
var damage = speed * DAMAGE_COEFFICIENT
var direction = null
var size = 1.0

func _ready():
	size = $CollisionShape2D.shape.radius
	if direction == null:
		direction = Vector2.RIGHT

func _process(delta):
	pass

func _physics_process(delta):
	update_position(delta)
	handle_logic()

func set_direction(dir: Vector2):
	direction = dir

func update_position(delta):
	position += direction * speed * delta

func handle_logic():
	pass
