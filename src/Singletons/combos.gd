extends Node

var timer: SceneTreeTimer

var is_combo_going: bool = false
var combo: int = 0

var combo_tolerance = 5.

var score: int = 0

func handle_hit(damage: int):
	timer = get_tree().create_timer(combo_tolerance)
	timer.timeout.connect(_on_combo_timer_timeout)
	is_combo_going = true
	combo += 1
	
	score += damage
	
	print("COMBO: ", combo)

func _on_combo_timer_timeout():
	is_combo_going = false
	combo = 0
