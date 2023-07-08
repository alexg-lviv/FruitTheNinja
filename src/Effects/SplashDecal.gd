extends Sprite2D

var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	set_texture(Projectiles.decal_textures[rng.randi_range(0, Projectiles.decal_textures.size() - 1)])
	show_decal()

func set_lifetime(time: float):
	$Timer.wait_time = time

func set_color(color: Color):
	var mat = get_material()
	mat.set_shader_parameter("col", color)

# Should be called to show the decal
func show_decal():
	$AnimationPlayer.play("fadein")
	$Timer.start()


func _on_timer_timeout():
	$AnimationPlayer.play("fadeout")
