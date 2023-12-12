extends Node

var frame_count: int = 0

# An array of data for multiple frames to send

const DEF_GLOBAL_FRAME_DATA := {
	"name": "global_data",
	"combo": 0,
	"is_combo_going": false,
	"phys_frames_since_last_combo": 0,
	"score": 0,
	"time_left_of_current_combo": 0,
	"global_mouse_position": [0.0, 0.0],
	"time_scalar": 0.0,
	"time_left": 0.0,
	"time_left_seconds": 0.0,
	"physical_dt": 0.0,
	"logical_dt": 0.0
}

const DEF_BUTTON_FRAME_DATA := {
	"name": "button_data",
	"logical_frames_since_last_button_press":
		{
			"b1": 0.0,
			"b2": 0.0,
			"b3": 0.0,
			"b4": 0.0
		},
	"button_cooldown_times":
		{
			"b1": 0.0,
			"b2": 0.0,
			"b3": 0.0,
			"b4": 0.0
		},
	"current_button": 0,
	"logical_frames_since_last_slowmo": 0,
	"is_in_slowmo": false,
	# from 0 to 0.5
	"slowmo_time_left_half_unit": 0.0
}

const DEF_NINJA_FRAME_DATA := {
	"name": "ninja_data",
	"speed": 0.0,
	"global_position": [0.0, 0.0],
	"velocity": [0.0, 0.0],
	"in_dash": false,
	"can_dash": false,
	"is_stunned": false,
	"dash_cooldown_time": 0.0,
	"fruits_cut_this_frame": 0,
	"got_bonked_this_frame": 0,
	"is_on_board": true,
}

const DEF_FRUITS_FRAME_DATA := {
	"name": "fruits_data",
	"is_aiming": false,
	"fruits_spawned_this_frame_list": [],
	"fruits_cut_this_frame_list": [],
	"fruits_hit_ninjas_ass_this_frame_list": [],
	"stupid_fucking_fruits_that_died_this_frame_list": [],
	"fruits_on_screen_this_frame": []
}

var fruits_spawned_this_frame_list = []
var fruits_on_screen_this_frame_list = []
var fruits_cut_this_frame_list = []
var fruits_hit_ninjas_ass_this_frame_list = []
var stupid_fucking_fruits_that_died_this_frame_list = []

var frame_data := []
var current_frame_data := []
var session_descriprion_frame_data := {}
var global_frame_data := {}
var button_frame_data := {}
var ninja_frame_data := {}
var lists_frame_data := {}

var should_log: bool = false
var session_id: int
var cheat_flag: int = 0

@onready var HttpRequestHandle := $HTTPRequest

var HEADERS := ["Content-Type: application/json"]
var URL := "http://127.0.0.1:8080/post_endpoint"

func _ready():
	_reset()

func _reset():
	frame_count = 0
	frame_data.clear()
	current_frame_data.clear()
	should_log = false
	session_id = _generate_game_session_id()
	
	session_descriprion_frame_data.clear()
	global_frame_data = DEF_GLOBAL_FRAME_DATA.duplicate()
	button_frame_data = DEF_BUTTON_FRAME_DATA.duplicate()
	ninja_frame_data = DEF_NINJA_FRAME_DATA.duplicate()
	lists_frame_data = DEF_FRUITS_FRAME_DATA.duplicate()

func enable():
	should_log = true

func stop():
	post_data()
	_reset()
	should_log = false

func is_logging():
	return should_log

# Called every time you start a battle
func _generate_game_session_id():
	return Time.get_unix_time_from_system()

func _log_data_type(dict, key, val):
	if should_log:
		dict[key] = val

func _log_description_data(key, val):
	_log_data_type(session_descriprion_frame_data, key, val)

func log_global_data(key, val):
	_log_data_type(global_frame_data, key, val)

func log_button_data(key, val):
	_log_data_type(button_frame_data, key, val)

func log_ninja_data(key, val):
	_log_data_type(ninja_frame_data, key, val)

func log_lists_data(key, val):
	_log_data_type(lists_frame_data, key, val)

func post_data():
	var json = JSON.stringify(frame_data)
	HttpRequestHandle.request(URL, HEADERS, HTTPClient.METHOD_POST, json)

func _log_misc_data(dt):
	_log_description_data("name", "session_description")
	_log_description_data("frame_count", frame_count)
	_log_description_data("session_id", session_id)
	_log_description_data("cheat_flag", cheat_flag)
	log_global_data("physical_dt", dt)

func combine_all_frame_data():

	current_frame_data.append(session_descriprion_frame_data.duplicate())
	current_frame_data.append(global_frame_data.duplicate())
	current_frame_data.append(button_frame_data.duplicate())
	current_frame_data.append(ninja_frame_data.duplicate())
	lists_frame_data["fruits_spawned_this_frame_list"] = fruits_spawned_this_frame_list.duplicate()
	lists_frame_data["fruits_cut_this_frame_list"] = fruits_cut_this_frame_list.duplicate()
	lists_frame_data["fruits_hit_ninjas_ass_this_frame_list"] = fruits_hit_ninjas_ass_this_frame_list.duplicate()
	lists_frame_data["stupid_fucking_fruits_that_died_this_frame_list"] = stupid_fucking_fruits_that_died_this_frame_list.duplicate()
	lists_frame_data["fruits_on_screen_this_frame_list"] = fruits_on_screen_this_frame_list.duplicate()
	current_frame_data.append(lists_frame_data.duplicate())
	fruits_spawned_this_frame_list = []
	fruits_cut_this_frame_list = []
	fruits_hit_ninjas_ass_this_frame_list = []
	stupid_fucking_fruits_that_died_this_frame_list = []
	fruits_on_screen_this_frame_list = []

# Unused for now
func log_current_frame_object_data(object):
	if should_log:
		var json = {
			"name": object.name
		}
		if object.get("global_position"):
			json["global_position"] = object.global_position
		for el in object.get_script().get_script_property_list():
			if el.type in [0, 7, 24]: continue
			
			if (el.type == 5):
				var v2d = object.get(el.name)
				json[el.name] = [v2d.x, v2d.y]
			else:
				json[el.name] = object.get(el.name)
		
		current_frame_data.append(json)

# Gather all data and post it if gathered enough
func gather_and_post(dt):
	frame_count += 1
	_log_misc_data(dt)
	
	combine_all_frame_data()
	frame_data.append(current_frame_data.duplicate())
	current_frame_data.clear()
	
	if (frame_count % 60 == 0):
		post_data()
		frame_data.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if should_log:
		call_deferred("gather_and_post", delta)

func _process(delta):
	if should_log:
		log_global_data("logical_dt", delta)
