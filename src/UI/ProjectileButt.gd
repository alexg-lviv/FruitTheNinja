extends TextureButton

@export var projectile: String
@export var cd: float

var projectile_texture
var projectile_scene: String


func _ready():
	set_physics_process(false)
	projectile_scene = "res://src/Projectiles/" + projectile + "/" + projectile + ".tscn"
	$Icon.texture = load("res://assets/fruits/" + projectile + ".png")
	projectile_texture = $Icon.texture
	$Timer.wait_time = cd
	$TextureProgressBar.max_value = cd
	$TextureProgressBar.value = 0


func _physics_process(delta):
	$TextureProgressBar.value = $Timer.time_left


func _on_launch():
	disabled = true
	$Timer.start()
	set_physics_process(true)


func _on_timer_timeout():
	disabled = false
	set_physics_process(false)
	$TextureProgressBar.value = 0
