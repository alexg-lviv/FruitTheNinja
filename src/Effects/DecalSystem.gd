extends Node2D

var rng = RandomNumberGenerator.new()

var DecalObj = preload("res://src/Effects/SplashDecal.tscn")

func add_decals(global_pos: Vector2, color: Color, size: float):
	
	var sizes = 0.006 * size
	for i in rng.randf_range(1, 4):
		var decalIns = DecalObj.instantiate()
		decalIns.set_lifetime(rng.randf_range(2, 4))
		decalIns.global_position = global_pos + Vector2(rng.randf_range(-32, 32), rng.randf_range(-32, 32))
		decalIns.set_color(color)
		var scale = sizes
		decalIns.scale = Vector2(scale, scale)
		add_child(decalIns)
		
		sizes -= randf_range(0.002, sizes / 2.0)
