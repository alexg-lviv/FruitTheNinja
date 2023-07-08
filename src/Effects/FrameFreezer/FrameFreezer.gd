extends Node


@export var delay_miliseconds: = 15


func _ready():
	await get_tree().create_timer(0.1).timeout
	Signals.frame_freeze_requested.connect(_on_frame_freeze_requested)


func _on_frame_freeze_requested(delay):
	OS.delay_msec(delay)
