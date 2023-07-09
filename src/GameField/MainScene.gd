extends Control

@export var populate_time: float

@export var slowmo_time: float
@export var slowmo_slow: float
@export var slowmo_cd: float

@onready var _projectiles_butts := []

@onready var _aim_rect = $AimField.get_rect() as Rect2
@onready var _ai_rect = $AiField.get_rect() as Rect2

var _preview

var _left_bar_tween

var _projectiles := [
	"Apple", "Banana", "Grape", "Pineapple", "Watermelon", "Coconut"
	]

var _actions := {
	"projectile_1": 0,
	"projectile_2": 1,
	"projectile_3": 2,
	"projectile_4": 3,
}

var _butt = preload("res://src/UI/ProjectileButt.tscn")

var _is_slowmo := false
@onready var _slowmo_timer = $SlowmoTimer
var _slowmo_tween
var _slowmo_inter_tween
var time_scalar: float = 10


func _ready():
	$PopulateTimer.wait_time = populate_time
	slowmo_time *= slowmo_slow
	_slowmo_timer.wait_time = slowmo_time
	$SlowmoProgress.max_value = slowmo_time
	set_physics_process(false)
	
	Signals.fruit_hit.connect(_on_fruit_hit)
	
	for i in range(4):
		var b = _butt.instantiate()
		b.projectile = _projectiles[randi() % _projectiles.size()]
		$VBoxLeft.get_node(str(i+1)).add_child(b)
		var t = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(b, "scale", Vector2.ONE, 0.8).from(Vector2.ZERO)
		t.tween_property(b, "rotation_degrees", 0, 0.8).from(90)
		
	$PopulateTimer.start()

func _process(delta):
	$LifetimeProgress.value = $LifetimeProgress.value - delta * time_scalar
	time_scalar += delta


func _physics_process(delta):
	$SlowmoProgress.value = _slowmo_timer.time_left


func _populate():
	for i in range(4):
		var butt = $VBoxLeft.get_child(i).get_child(0)
		if butt.butt.disabled:
			_projectiles_butts.erase(butt)
			var t = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			t.tween_property(butt, "scale", Vector2.ZERO, 0.5)
			t.tween_property(butt, "rotation_degrees", -90, 0.5)
			await t.finished
			butt.queue_free()
			
			var b = _butt.instantiate()
			b.projectile = _projectiles[randi() % _projectiles.size()]
			$VBoxLeft.get_child(i).add_child(b)
			var t2 = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t2.tween_property(b, "scale", Vector2.ONE, 0.8).from(Vector2.ZERO)
			t2.tween_property(b, "rotation_degrees", 0, 0.8).from(90)


func _input(event):
	for action in _actions:
		if event.is_action_pressed(action) and _actions[action] <= len(_projectiles) - 1:
			if $VBoxLeft.get_child(_actions[action]).get_child_count() > 0 and not $VBoxLeft.get_child(_actions[action]).get_child(0).butt.disabled:
				if _preview != null:
					_preview.queue_free()
					await _preview.tree_exited
				launch_butt($VBoxLeft.get_child(_actions[action]).get_child(0))
	
	if event.is_action_pressed("ui_cancel") and _preview != null:
		_preview.queue_free()
	
	if event.is_action_pressed("slowmo"):
		if _is_slowmo:
			_reset_time_scale()
		else:
			if _slowmo_tween and _slowmo_tween.is_running():
				_slowmo_tween.kill()
				
			if _slowmo_inter_tween and _slowmo_inter_tween.is_running():
				_slowmo_inter_tween.kill()
			_slowmo_inter_tween = get_tree().create_tween().set_parallel()
			_slowmo_inter_tween.tween_property(Engine, "time_scale", slowmo_slow, 0.1).from(0.7)
			_slowmo_inter_tween.tween_property($AudioStreamPlayer, "pitch_scale", 0.8, 0.5)
				
			$CanvasLayer/SlowMoEffect.activate()
			
			_is_slowmo = true
			set_physics_process(true)
			_slowmo_timer.start()


func _on_slowmo_timer_timeout():
	_reset_time_scale()


func _reset_time_scale():
	$CanvasLayer/SlowMoEffect.deactivate()
	
	if _slowmo_inter_tween and _slowmo_inter_tween.is_running():
		_slowmo_inter_tween.kill()
	_slowmo_inter_tween = get_tree().create_tween().set_parallel()
	_slowmo_inter_tween.tween_property(Engine, "time_scale", 1, 0.3)
	_slowmo_inter_tween.tween_property($AudioStreamPlayer, "pitch_scale", 1, 0.3)
	
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


func launch_butt(butt):
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
	butt.butt.disabled = true


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

func _on_fruit_hit(damage: int):
	Combos.handle_hit()
	var combo = Combos.combo
	$LifetimePlayer.play("add_hp")
#	$LifetimeProgress.value += damage * combo
	var tween = create_tween()
	tween.tween_property($LifetimeProgress, "value", $LifetimeProgress.value + damage * combo, 0.5)
	time_scalar -= damage * combo / 50.

func _on_populate_timer_timeout():
	_populate()
