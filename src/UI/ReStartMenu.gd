extends Control


func activate(score: int):
	$AnimationPlayer.play("appear")
	get_parent().visible = true
	
	$TextureRect/Label.text = "Your score: %s" % str(score)


func _on_button_pressed():
	$AnimationPlayer.play("dissapear")
	await $AnimationPlayer.animation_finished
	get_parent().visible = false
	Signals.emit_signal("menu_start_button_pressed")
