extends ColorRect

func activate():
	$AnimationPlayer.play("fadein")


func deactivate():
	$AnimationPlayer.play("fadeout")
