extends Marker2D


var _init_scale := Vector2(1, 1)
var _peak_scale := Vector2(2, 2)


var _first_time = 0.3
var _second_time = 0.1

var _velocity := Vector2(36, 36)

var value: int

@onready var _label = $Label

func set_label(text: String):
	_label.text = text
	value = int(text)
	return self

func set_color(color: Color):
	_label.set("custom_colors/font_color", color)
	return self

func set_time(first_time, second_time):
	_first_time = first_time
	_second_time = second_time


func animate():
	var _tween = get_tree().create_tween()
	_velocity *= _peak_scale.length()
	scale = _init_scale
	_tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", _peak_scale, _first_time)
	_tween.tween_property(self, "scale", Vector2(_init_scale.x + value / 1000., _init_scale.y + value / 1000.), _second_time)
