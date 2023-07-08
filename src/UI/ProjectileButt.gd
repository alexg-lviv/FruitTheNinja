extends TextureButton

@export var projectile: String

var projectile_texture
var projectile_scene: String

func _ready():
	projectile_scene = "res://src/Projectiles/" + projectile + "/" + projectile + ".tscn"
	$Icon.texture = load("res://assets/fruits/" + projectile + ".png")
	projectile_texture = $Icon.texture

