extends Control


const _valid_modulate = Color(1, 1, 1, 0.7)
const _invalid_modulate = Color(1, 0.2, 0.2, 0.8)

var _projectile_scene

var _is_valid: bool
var _is_locked: bool

var _lock_position: Vector2
var _prev_mouse_position: Vector2

var _aim_rect: Rect2
var _ai_rect: Rect2

func _physics_process(delta):
	var _pos = get_global_mouse_position()
	_update_validness(_pos)
	
	if _is_locked:
		if _ai_rect.has_point(_pos):
			pass
		elif not _aim_rect.has_point(_pos):
			_draw_line(_prev_mouse_position)
		else:
			_draw_line(_pos)
	else:
		_draw_icon(_pos)

func init_set(proj_scene, proj_texture, aim_rect, ai_rect):
	_projectile_scene = proj_scene
	$Position/Icon.texture_normal = proj_texture
	_is_locked = false
	_aim_rect = aim_rect
	_ai_rect = ai_rect

func _update_validness(_pos):
	_is_valid = _aim_rect.has_point(_pos) and not _ai_rect.has_point(_pos)

func _draw_icon(pos):
	$Position.position = pos
	$Position.self_modulate = _valid_modulate if _is_valid else _invalid_modulate

func _draw_line(pos):
	_prev_mouse_position = pos
#	draw_line(_lock_position, pos, Color.WHITE)


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if _is_locked:
				Projectiles.spawned_projectiles.append(_projectile_scene.instantiate())
			else:
				_is_locked = true
				_lock_position = get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_RIGHT:
				queue_free()
