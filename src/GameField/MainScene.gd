extends Control

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


func _ready():
	print(_ai_rect)
	for butt in _projectiles_butts:
		butt.pressed.connect(_on_projectile_butt_pressed.bind(butt))


func _input(event):
	for action in _launch_actions:
		if event.is_action_pressed(action):
			if _preview != null:
				_preview.queue_free()
				await _preview.tree_exited
			_on_projectile_butt_pressed(_launch_actions[action])
	
	if event.is_action_pressed("ui_cancel") and _preview != null:
		_preview.queue_free()
		


func _on_projectile_butt_pressed(butt):
	_preview = load("res://src/ProjectilesLauncher/Launcher.tscn").instantiate()
	$CanvasLayer.add_child(_preview)
	_preview.init_set(butt.projectile_scene, butt.projectile_texture, _aim_rect, _ai_rect)
	_preview.spawn_projectile.connect(_spawn_projectile)
	
	_hide_bars()
	_preview.tree_exited.connect(_show_bars)
	

func _spawn_projectile(projectile, pos, direction):
	$Projectiles.add_child(projectile)
	projectile.position = pos
	projectile.set_direction(direction)
	Projectiles.spawned.append(projectile)


func _show_bars():
	if _left_bar_tween and _left_bar_tween.is_running():
		_left_bar_tween.kill()
	_left_bar_tween = get_tree().create_tween()
	_left_bar_tween.tween_property($VBoxLeft, "offset_left", 50, 0.3)


func _hide_bars():
	if _left_bar_tween and _left_bar_tween.is_running():
		_left_bar_tween.kill()
	_left_bar_tween = get_tree().create_tween()
	_left_bar_tween.tween_property($VBoxLeft, "offset_left", -300, 0.3)
