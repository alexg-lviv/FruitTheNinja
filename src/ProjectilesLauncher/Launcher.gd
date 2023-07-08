extends Control

signal spawn_projectile(projectile, pos, direction)

const _valid_modulate = Color.GREEN
const _invalid_modulate = Color.RED

var _projectile_scene

var _is_valid: bool
var _is_locked: bool

var _lock_position: Vector2

var _aim_rect: Rect2
var _ai_rect: Rect2


func _physics_process(delta):
	var _pos = get_global_mouse_position()
	_update_validness(_pos)
	
	if _is_locked:
		_draw_speed(_pos, delta)
	else:
		_draw_icon(_pos)

func _ready():
	visible = false

func init_set(proj_scene, proj_texture, aim_rect, ai_rect):
	_projectile_scene = proj_scene
	$Position/Icon.texture_normal = proj_texture
	_is_locked = false
	_aim_rect = aim_rect
	_ai_rect = ai_rect
	visible = true

func _update_validness(_pos):
	_is_valid = _aim_rect.has_point(_pos) and not _ai_rect.has_point(_pos)

func _draw_icon(pos):
	$Position.position = pos
	$Position/Icon.self_modulate = _valid_modulate if _is_valid else _invalid_modulate

func _draw_speed(pos, delta):
	var distance = _lock_position.distance_to(pos)
	$Position/Speed.value = distance
	var direction = (_lock_position - get_global_mouse_position()).normalized()
	$Position.rotation = direction.angle()
	
	$Position/Trajectory/ProjectileTrajectory.update_trajectory(direction, 500, 5, 0.1, delta)

func _on_gui_input(event):
	if event.is_action_pressed("aim") and _is_valid:
		_is_locked = true
		_lock_position = get_global_mouse_position()
	
	if event.is_action_released("aim") and _is_locked:
		var direction = (_lock_position - get_global_mouse_position()).normalized()
		if direction.length() <= 0.05:
			_is_locked = false
		else:
			emit_signal("spawn_projectile", load(_projectile_scene).instantiate(), _lock_position, direction)
			queue_free()
