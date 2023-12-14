extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func e():
	Logger.cheat_flag = 0

func remove_fruit_kd():
	get_node("/root/MainScene/PopulateTimer").wait_time = 0.01
	Logger.cheat_flag = 1

func remove_dash():
	get_node("/root/MainScene/Player").can_dash = false
	Logger.cheat_flag = 2

# Works best with cheat 1
func infinite_slowmo():
	get_node("/root/MainScene/SlowmoTimer").wait_time = 1337228
	Logger.cheat_flag = 3

func move_player_outside():
	get_node("/root/MainScene/Player").global_position = Vector2(10, 10)
	Logger.cheat_flag = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	e()
#	remove_fruit_kd()
#	remove_dash()
#	infinite_slowmo()
#	move_player_outside()
