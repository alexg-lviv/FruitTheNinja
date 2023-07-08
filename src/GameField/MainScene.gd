extends Control

@export var slowmo_time: float
@export var slowmo_slow: float
@export var slowmo_cd: float

@onready var _projectiles_butts = $VBoxLeft.get_children()

@onready var _aim_rect = $AimField.get_rect() as Rect2
@onready var _ai_rect = $AiField.get_rect() as Rect2

var _preview

var _left_bar_tween

@onready var _launch_actions := {
	"launch_apple": $VBoxLeft/Apple,
	"launch_banana": $VBoxLeft/Banana,
	"launch_grape": $VBoxLeft/Grape,
	"launch_pineapple": $VBoxLeft/Pineapple,
	"launch_watermelon": $VBoxLeft/Watermelon,
}

var _is_slowmo := false
@onready var _slowmo_timer = $SlowmoTimer
var _slowmo_tween


func _ready():
	slowmo_time *= slowmo_slow
	print(slowmo_time)
	_slowmo_timer.wait_time = slowmo_time
	$SlowmoProgress.max_value = slowmo_time
	set_physics_process(false)
	for butt in _projectiles_butts:
		butt.pressed.connect(_on_projectile_butt_pressed.bind(butt))


func _physics_process(delta):
	$SlowmoProgress.value = _slowmo_timer.time_left


func _input(event):
	for action in _launch_actions:
		if event.is_action_pressed(action):
			if _preview != null:
				_preview.queue_free()
				await _preview.tree_exited
			if not _launch_actions[action].disabled:
				_launch_actions[action].emit_signal("pressed")
	
	if event.is_action_pressed("ui_cancel") and _preview != null:
		_preview.queue_free()
	
	if event.is_action_pressed("slowmo"):
		if _is_slowmo:
			_reset_time_scale()
		else:
			if _slowmo_tween and _slowmo_tween.is_running():
				_slowmo_tween.kill()
			Engine.time_scale = slowmo_slow
			_is_slowmo = true
			set_physics_process(true)
			_slowmo_timer.start()


func _on_slowmo_timer_timeout():
	_reset_time_scale()


func _reset_time_scale():
	Engine.time_scale = 1
	_is_slowmo = false
	set_physics_process(false)
	
	_slowmo_timer.wait_time = clampf(_slowmo_timer.time_left, 0.00001, slowmo_time)
	_slowmo_timer.stop()
	_reload_slowmo_timer()


func _reload_slowmo_timer():
	if _slowmo_tween and _slowmo_tween.is_running():
		_slowmo_tween.kill()
	_slowmo_tween = get_tree().create_tween().set_parallel()
	_slowmo_tween.tween_property(_slowmo_timer, "wait_time", slowmo_time, (1 - _slowmo_timer.wait_time / slowmo_time) * slowmo_cd)
	_slowmo_tween.tween_property($SlowmoProgress, "value", slowmo_time, slowmo_cd)


func _on_projectile_butt_pressed(butt):
	_preview = load("res://src/ProjectilesLauncher/Launcher.tscn").instantiate()
	$CanvasLayer.add_child(_preview)
	_preview.init_set(butt, _aim_rect, _ai_rect)
	_preview.spawn_projectile.connect(_spawn_projectile.bind(butt))
	
	_hide_bars()
	_preview.tree_exited.connect(_show_bars)
	

func _spawn_projectile(projectile, pos, direction, speed_coef, butt):
	$Projectiles.add_child(projectile)
	projectile.position = pos
	projectile.speed *= speed_coef
	projectile.set_direction(direction)
	Projectiles.spawned.append(projectile)
	
	butt._on_launch()
	
	_on_projectile_butt_pressed(butt)


func _show_bars():
	if _left_bar_tween and _left_bar_tween.is_running():
		_left_bar_tween.kill()
	_left_bar_tween = get_tree().create_tween()
	_left_bar_tween.tween_property($VBoxLeft, "position", Vector2(50, 100), 0.3)


func _hide_bars():
	if _left_bar_tween and _left_bar_tween.is_running():
		_left_bar_tween.kill()
	_left_bar_tween = get_tree().create_tween()
	_left_bar_tween.tween_property($VBoxLeft, "position", Vector2(-50, 100), 0.3)
