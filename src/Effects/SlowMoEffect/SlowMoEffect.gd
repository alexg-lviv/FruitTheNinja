extends ColorRect

var opacity: float = 0.0

var fadein_tween = null
var fadeout_tween = null

func activate():
	if (fadeout_tween != null):
		fadeout_tween.stop()
	fadein_tween = create_tween()
	fadein_tween.tween_property(self, "opacity", 1.0, 0.1)
	#$AnimationPlayer.play("fadein")

func _process(delta):
	var mat = get_material()
	mat.set_shader_parameter("alpha", opacity);

func deactivate():
	if (fadein_tween != null):
		fadein_tween.stop()
	fadeout_tween = create_tween()
	fadeout_tween.tween_property(self, "opacity", 0.0, 0.8)
	#$AnimationPlayer.play("fadeout")
