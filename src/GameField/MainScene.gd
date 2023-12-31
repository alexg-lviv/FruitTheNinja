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
	"Apple", "Banana", "Grape", "Pineapple", "Watermelon", "Coconut", "Cherry"
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

var _combo_text = preload("res://src/UI/ComboText.tscn")
var _combo_colors := [Color("00ffff"), Color("5482ff"), Color("d09aff"), Color("9bff70"), Color("afff5e"), Color("ff9c6b"), Color("c387ff")]

var _pulse_count = 0

var _rrr := true

# Logging vars
var logical_frames_since_last_slowmo: int = 0

var logical_frames_since_last_buttons_press := {
	"b1": 0,
	"b2": 0,
	"b3": 0,
	"b4": 0
}
var buttons_cooldown_times := {
	"b1": 0,
	"b2": 0,
	"b3": 0,
	"b4": 0
}

const BUT_IDX_LOOKUP_TABLE = {
	0: "b1",
	1: "b2",
	2: "b3",
	3: "b4",
}

# 0 - None, 1-4 - buttons
var current_button: int = 0


func _ready():
	Signals.menu_start_button_pressed.connect(_start)
	$PopulateTimer.wait_time = populate_time
	slowmo_time *= slowmo_slow
	_slowmo_timer.wait_time = slowmo_time
	$SlowmoProgress.max_value = slowmo_time
	set_physics_process(false)
	
	Signals.fruit_hit.connect(_on_fruit_hit)
	Signals.cheater.connect(_cheater_detected)
	
	_stop()

func _start():
	Logger.enable()
	
	for i in range(4):
		if $VBoxLeft.get_child(i).get_child(0):
			$VBoxLeft.get_child(i).get_child(0).queue_free()
	
	Combos.score = 0
	time_scalar = 10
	$LifetimeProgress.value = 500
	$ScoreLabel.get_node("Label").text = "0"
	
	for i in range(4):
		var b = _butt.instantiate()
		b.projectile = _projectiles[randi() % _projectiles.size()]
		$VBoxLeft.get_node(str(i+1)).add_child(b)
		b.get_node("T/Label").text = str(i+1)
		var t = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(b, "scale", Vector2.ONE, 0.8).from(Vector2.ZERO)
		t.tween_property(b, "rotation_degrees", 0, 0.8).from(90)
		
	$PopulateTimer.start()
	$PulseTimer.start()
	
	set_process_input(true)
	set_process(true)


func _stop():
	Logger.stop()
	Combos.score = 0
	set_process_input(false)
	set_process(false)

func log_data():
	Logger.log_global_data("time_scalar", time_scalar)
	Logger.log_global_data("time_left", $LifetimeProgress.value)
	Logger.log_global_data("time_left_seconds", $LifetimeProgress.value / time_scalar)
	
	Logger.log_button_data("is_in_slowmo", _is_slowmo)
	Logger.log_button_data("slowmo_time_left_half_unit", $SlowmoProgress.value)
	Logger.log_button_data("logical_frames_since_last_slowmo", logical_frames_since_last_slowmo)
	Logger.log_button_data("current_button", current_button)
	Logger.log_button_data("button_cooldown_times", buttons_cooldown_times.duplicate())
	Logger.log_button_data("logical_frames_since_last_button_press", logical_frames_since_last_buttons_press.duplicate())


func _process(delta):
	$LifetimeProgress.value = $LifetimeProgress.value - delta * time_scalar
	time_scalar += delta
	if !_is_slowmo:
		logical_frames_since_last_slowmo += 1
	
	for b in logical_frames_since_last_buttons_press:
		if b in [0, current_button]:
			continue
		logical_frames_since_last_buttons_press[b] += 1
	
	for i in range(4):
		var butt = $VBoxLeft.get_child(i).get_child(0)
		if butt.butt.disabled:
			buttons_cooldown_times[BUT_IDX_LOOKUP_TABLE[i]] = $PopulateTimer.time_left
	
	log_data()
	if $LifetimeProgress.value == 0:
		$CanvasLayer2/ReStartMenu.activate(Combos.score)
		_stop()


func _physics_process(delta):
	$SlowmoProgress.value = _slowmo_timer.time_left


func _populate():
	for i in range(4):
		var butt = $VBoxLeft.get_child(i).get_child(0)
		if butt.butt.disabled:
			buttons_cooldown_times[BUT_IDX_LOOKUP_TABLE[i]] = 0
			_projectiles_butts.erase(butt)
			var t = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			t.tween_property(butt, "scale", Vector2.ZERO, 0.5)
			t.tween_property(butt, "rotation_degrees", -90, 0.5)
			await t.finished
			if is_instance_valid(butt):
				butt.queue_free()
			
			var b = _butt.instantiate()
			b.projectile = _projectiles[randi() % _projectiles.size()]
			$VBoxLeft.get_child(i).add_child(b)
			b.get_node("T/Label").text = str(i+1)
			var t2 = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t2.tween_property(b, "scale", Vector2.ONE, 0.8).from(Vector2.ZERO)
			t2.tween_property(b, "rotation_degrees", 0, 0.8).from(90)


func _input(event):
	if _rrr:
		for action in _actions:
			if event.is_action_pressed(action) and _actions[action] <= len(_projectiles) - 1:
				if $VBoxLeft.get_child(_actions[action]).get_child_count() > 0 and not $VBoxLeft.get_child(_actions[action]).get_child(0).butt.disabled:
					if (current_button != _actions[action] + 1):
						logical_frames_since_last_buttons_press[BUT_IDX_LOOKUP_TABLE[_actions[action]]] = 0
						current_button = _actions[action] + 1
					if _preview != null:
						$ChooseSound.play()
						_preview.queue_free()
						await _preview.tree_exited
					_rrr = false
					launch_butt($VBoxLeft.get_child(_actions[action]).get_child(0))
					await get_tree().create_timer(0.001).timeout
					_rrr = true
	
	if event.is_action_pressed("ui_cancel") and _preview != null:
		current_button = 0
		_preview.queue_free()
	
	if event.is_action_pressed("slowmo"):
		if _is_slowmo:
			_reset_time_scale()
		else:
			logical_frames_since_last_slowmo = 0
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
	$ThrowSound.play()
	$Projectiles.add_child(projectile)
	projectile.position = pos
	projectile.speed *= speed_coef
	projectile.set_direction(direction)
	Projectiles.spawned.append(projectile)
	butt.butt.disabled = true
	
	Logger.fruits_spawned_this_frame_list.append(projectile.get_fruit_metadata().duplicate())


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

func _on_fruit_hit(damage: int, impact_position: Vector2):
#	damage = 10932329
#	Logger.cheat_flag = 4
	Combos.handle_hit(damage)
	var combo = Combos.combo
	$LifetimePlayer.play("add_hp")
	var tween = create_tween()
	tween.tween_property($LifetimeProgress, "value", $LifetimeProgress.value + damage * combo, 0.5)
	#time_scalar -= damage * combo / 40.
	
	$ScoreLabel.set_label(str(Combos.score))
	
	var popup = _combo_text.instantiate()
	$CanvasLayer.add_child(popup)
	popup.position = impact_position + Vector2(50 - randi() % 100, 50 - randi() % 100)
	if combo == 1:
		popup.get_node("Label").text = "HIT"
	else:
		popup.get_node("Label").text = "COMBO x" + str(combo)
	popup.modulate = Projectiles.colors[randi() % len(Projectiles.colors)]
	
	var popup_tween = get_tree().create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	popup_tween.tween_property(popup, "scale", Vector2.ONE + 0.1 * (combo-1+randf_range(1,5)) * Vector2.ONE, 0.5).from(Vector2.ZERO)
	popup_tween.tween_property(popup, "rotation_degrees", 20 - randi() % 40, 0.5).from(90)
	
	await get_tree().create_timer(1 + 0.2 * (1-combo)).timeout
	
	popup_tween = get_tree().create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	popup_tween.tween_property(popup, "scale", Vector2.ZERO, 0.3)
	popup_tween.tween_property(popup, "rotation_degrees", 180, 0.3)
	await popup_tween.finished
	
	popup.queue_free()

func _on_populate_timer_timeout():
	_populate()

func _on_pulse_timer_timeout():
	_pulse_count += 1
	if _pulse_count >= 3:
		return

	for i in range(2):
		var _tween = get_tree().create_tween()
		_tween.tween_property($Pulse, "modulate:a", 0.4, 0.4).from(0.).set_ease(Tween.EASE_OUT)
		_tween.tween_property($Pulse, "modulate:a", 0., 0.4).set_ease(Tween.EASE_IN)
		await _tween.finished
	$PulseTimer.start()


func _cheater_detected(detected: int):
	if detected == 0:
		$Cheater.text = "Not Cheater"
		$Cheater.label_settings.font_color = Color("#a6e3a6")
		$Cheater.label_settings.outline_color = Color("#62a683")
	else:
		$Cheater.text = "Cheated!!!!"
		$Cheater.label_settings.font_color = Color("#df0059")
		$Cheater.label_settings.outline_color = Color("#b5161d")
		
