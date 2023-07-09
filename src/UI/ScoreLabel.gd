extends Marker2D


var _init_scale := Vector2(1, 1)
var _peak_scale := Vector2(2, 2)


var _first_time = 0.3
var _second_time = 0.1

var _velocity := Vector2(36, 36)

var value: int

@onready var _label = $Label

var _combo = preload("res://src/UI/ComboText.tscn")

var _tween


func set_label(text: String):
	var delta = int(text) - value
	var p = _combo.instantiate()
	$Marker2D.add_child(p)
	p.position += Vector2(20 - randi() % 40, 20 - randi() % 40)
	p.get_node("Label").text = str("+") + str(delta)
	p.modulate = Projectiles.colors[randi() % len(Projectiles.colors)]
	
	var t = get_tree().create_tween().set_parallel()
	t.tween_property(p, "scale", Vector2.ZERO, 1).from(randf_range(0.5, 3) * Vector2.ONE)
	t.tween_property(p, "position", p.position + Vector2(100 - randi() % 200, 100 - randi() % 200), 1)
	
	_label.text = text
	value = int(text)
	
	animate()
	
	await t.finished
	
	return self


func animate():
	if _tween and _tween.is_running():
		_tween.kill()
	
	_tween = get_tree().create_tween()
	_tween.tween_property($Label, "scale", 1.2 * Vector2.ONE, 0.1)
	_tween.tween_property($Label, "scale", Vector2.ONE, 0.2)
