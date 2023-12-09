extends "res://src/Projectiles/Projectile.gd"

class_name Grape

const CHILD_NUM: int = 5
const CHILD_SPEED: int = 300

var is_supposed_to_die: bool = false

var GrapeChild = preload("res://src/Projectiles/Grape/GrapeChild.tscn")

var rng = RandomNumberGenerator.new()

func get_p_name():
	return "Grape"

func _ready():
	super._ready()
	speed = 350
	color = Color(0.445, 0.195, 0.750)

func handle_logic():
	if (is_supposed_to_die):
		_create_children()
		Signals.emit_signal("camera_shake_requested", size, 0.2)
		Signals.emit_signal("frame_freeze_requested", 10)
		crash()

func _create_children():
	for i in CHILD_NUM:
		var ins = GrapeChild.instantiate()
		var base_dir_ang = direction.angle()
		base_dir_ang += rng.randf_range(-PI / 12.0, PI / 12.0)
		ins.global_position = global_position
		ins.direction = Vector2.RIGHT.rotated(base_dir_ang)
		ins.speed = CHILD_SPEED + rng.randi_range(-75, 75)
		Projectiles.spawned.append(ins)
		get_parent().add_child(ins)
	

func _on_die_timer_timeout():
	is_supposed_to_die = true
