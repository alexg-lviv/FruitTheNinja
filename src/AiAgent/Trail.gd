extends Line2D

class_name Trail

const MAX_POINTS = 500
@onready var curve := Curve2D.new()

func _process(delta):
	curve.add_point(get_parent().position)
	if curve.get_baked_points().size() > MAX_POINTS:
		curve.remove_point(0)
	
	points = curve.get_baked_points()

func stop():
	set_process(false)
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 1.0)
	await tw.finished
	queue_free()
	
static func create() -> Trail:
	var scn = preload("res://src/AiAgent/Trail.tscn")
	return scn.instantiate()
