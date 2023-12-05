extends Node

var frame_count: int = 0

# An array of data for multiple frames to send
var frame_data := []
var current_frame_data := []

@onready var HttpRequestHandle := $HTTPRequest

var HEADERS := ["Content-Type: application/json"]
var URL := "http://127.0.0.1:8080/post_endpoint"

func post_data():
	var json = JSON.stringify(frame_data)
	HttpRequestHandle.request(URL, HEADERS, HTTPClient.METHOD_POST, json)

func log_misc_data():
	current_frame_data.append({"name": "misc", "frame_count": frame_count})

# Unused for now
func log_current_frame_object_data(object):
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	frame_count += 1
	log_misc_data()
	
	frame_data.append(current_frame_data.duplicate())
	current_frame_data.clear()
	
	if (frame_count % 60 == 0):
		post_data()
		frame_data.clear()

