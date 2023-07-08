extends "res://src/Projectiles/Projectile.gd"

const CHILD_NUM: int = 7
const CHILD_SPEED: int = 300

var is_supposed_to_die: bool = false

var GrapeChild = preload("res://src/Projectiles/Grape/GrapeChild.tscn")

var rng = RandomNumberGenerator.new()

func _ready():
	super._ready()
	speed = 350


func handle_logic():
	if (is_supposed_to_die):
		_create_children()
		die()

func _create_children():
	for i in CHILD_NUM:
		var ins = GrapeChild.instantiate()
		var base_dir_ang = direction.angle()
		base_dir_ang += rng.randf_range(-PI / 6.0, PI / 6.0)
		ins.global_position = global_position
		ins.direction = Vector2.RIGHT.rotated(base_dir_ang)
		ins.speed = CHILD_SPEED + rng.randi_range(-75, 75)
		get_parent().add_child(ins)
	

func _on_die_timer_timeout():
	is_supposed_to_die = true
