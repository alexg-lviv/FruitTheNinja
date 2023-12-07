extends Node

var timer: SceneTreeTimer

var is_combo_going: bool = false
var phys_frames_since_last_combo: int = 0
var combo: int = 0

var combo_tolerance = 5.

var score: int = 0

func get_timer_time_left():
	if timer != null:
		return timer.time_left
	return 0

func log_data():
	Logger.log_global_data("score", score)
	Logger.log_global_data("combo", combo)
	Logger.log_global_data("phys_frames_since_last_combo", phys_frames_since_last_combo)
	Logger.log_global_data("is_combo_going", is_combo_going)
	Logger.log_global_data("time_left_of_current_combo", get_timer_time_left())

func _physics_process(delta):
	if (!is_combo_going && Logger.is_logging()):
		phys_frames_since_last_combo += 1
	log_data()

func handle_hit(damage: int):
	timer = get_tree().create_timer(combo_tolerance)
	timer.timeout.connect(_on_combo_timer_timeout)
	is_combo_going = true
	phys_frames_since_last_combo = 0
	combo += 1
	
	score += damage
	
	#print("COMBO: ", combo)

func _on_combo_timer_timeout():
	is_combo_going = false
	combo = 0
