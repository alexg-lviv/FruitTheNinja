extends Control

@onready var _projectiles_bar = $ProjectilesBar as Control
@onready var _projectiles_butts = $ProjectilesBar/VBox.get_children()

@onready var _aim_rect = $AimField.get_rect() as Rect2
@onready var _ai_rect = $AiField.get_rect() as Rect2

var _preview


func _ready():
	for butt in _projectiles_butts:
		butt.pressed.connect(_on_projectile_butt_pressed.bind(butt))


func _on_projectile_butt_pressed(butt):
	_preview = load("res://src/UI/ProjectilePreview.tscn").instantiate()
	$CanvasLayer.add_child(_preview)
	_preview.spawn_projectile.connect(_spawn_projectile)
	_preview.init_set(butt.projectile_scene, butt.projectile_texture, _aim_rect, _ai_rect)


func _spawn_projectile(projectile, pos, direction):
	$Projectiles.add_child(projectile)
	projectile.position = pos
	projectile.set_direction(direction)
