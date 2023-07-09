extends Control

signal spawn_projectile(projectile, pos, direction, speed_coef)

const _valid_modulate = Color.WHITE
const _invalid_modulate = Color("993234")

var _projectile_scene
var _butt

var _is_valid: bool
var _is_locked: bool

var _lock_position: Vector2

var _aim_rect: Rect2
var _ai_rect: Rect2

@onready var _base_tint = $Position/Speed.tint_progress.g


func _physics_process(delta):
	var _pos = get_global_mouse_position()
	_update_validness(_pos)
	
	if _is_locked:
		_draw_speed(_pos, delta)
	else:
		_draw_icon(_pos)

func _ready():
	visible = false

func init_set(butt, aim_rect, ai_rect):
	_butt = butt.butt
	_projectile_scene = butt.projectile_scene
	$Position/Icon.texture_normal = butt.projectile_texture
	_is_locked = false
	_aim_rect = aim_rect
	_ai_rect = ai_rect
	
	visible = true
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
	tween.tween_property($Position/Icon, "scale", Vector2.ONE, 0.3).from(Vector2.ZERO)
	tween.tween_property($Position/Icon, "rotation_degrees", 0, 0.3).from(120)

func _update_validness(_pos):
	if (!is_instance_valid(_butt)):
		return
	_is_valid = _aim_rect.has_point(_pos) and not _ai_rect.has_point(_pos) and not _butt.disabled

func _draw_icon(pos):
	$Position.position = pos
	$Position/Icon.self_modulate = _valid_modulate if _is_valid else _invalid_modulate

func _draw_speed(pos, delta):
	var distance = _lock_position.distance_to(pos)
	$Position/Speed.value = distance
	var direction = (_lock_position - get_global_mouse_position()).normalized()
	$Position.rotation = direction.angle()
	$Position/Speed.tint_progress.g = _base_tint - clampf(distance, 1, 100) / 200
	
	$ProjectileTrajectory.global_position = _lock_position / 2
	var speed_coef = clampf(0.005 * distance, 0.01, 0.25)
	$ProjectileTrajectory.update_trajectory(direction, 500, 10, speed_coef, delta, 0.0, false, Vector3($Position/Speed.tint_progress.r, $Position/Speed.tint_progress.g, $Position/Speed.tint_progress.b))

func _on_gui_input(event):
	if event.is_action_pressed("aim") and _is_valid:
		_is_locked = true
		_lock_position = get_global_mouse_position()
	
	if event.is_action_released("aim") and _is_locked:
		var direction = (_lock_position - get_global_mouse_position()).normalized()
		if direction.length() <= 0.05:
			_is_locked = false
		else:
			var distance = _lock_position.distance_to(get_global_mouse_position())
			var speed_coef = clampf(0.01 * distance, 0.5, 1.2)
			emit_signal("spawn_projectile", load(_projectile_scene).instantiate(), _lock_position, direction, speed_coef)
			queue_free()
