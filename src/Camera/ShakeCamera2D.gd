extends Camera2D


@onready var ShakeTimer: Timer = get_node("ShakeTimer")

@export var amplitude: = 6.0
@export var _duration: = 0.4
@export_exp_easing var damp_easing
@export var _shake: = false: set = set_shake

var shake_enabled: bool = true

func _ready():
	randomize()
	set_process(false)
	set_duration(_duration)
	await get_tree().create_timer(0.1).timeout
	connect_to_shakers()


func _physics_process(delta):
	var damping: = ease(ShakeTimer.time_left / ShakeTimer.wait_time, damp_easing)
	offset = Vector2(
		randf_range(amplitude, -amplitude) * damping,
		randf_range(amplitude, -amplitude) * damping
	) 


func set_duration(duration: float):
	_duration = duration
	ShakeTimer.wait_time = duration


func set_amplitude(amp):
	amplitude = amp


func set_shake(shake):
	_shake = shake
	set_process(shake)
	offset = Vector2()
	if shake:
		ShakeTimer.start()


func connect_to_shakers():
	Signals.camera_shake_requested.connect(_on_camera_shake_requested)


func _on_camera_shake_requested(amp, dur):
	if !shake_enabled:
		return
	set_amplitude(amp)
	set_duration(dur)
	set_shake(true)


func _on_shake_timer_timeout():
	set_shake(false)
