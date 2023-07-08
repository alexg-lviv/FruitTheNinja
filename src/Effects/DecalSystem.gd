extends Control

var rng = RandomNumberGenerator.new()

var DecalObj = preload("res://src/Effects/SplashDecal.tscn")

func add_decals(global_pos: Vector2, color: Color, size: float):
	
	var sizes = 0.006 * (2 + size) / 2.0
	for i in rng.randf_range(1, 4):
		var decalIns = DecalObj.instantiate()
		decalIns.set_lifetime(rng.randf_range(15, 30))
		decalIns.set_color(color)
		var scale = sizes
		decalIns.scale = Vector2(scale, scale)
		add_child(decalIns)
		decalIns.global_position = global_pos + Vector2(rng.randf_range(-32, 32), rng.randf_range(-32, 32))
		
		sizes -= randf_range(0.002, sizes / 2.0)
