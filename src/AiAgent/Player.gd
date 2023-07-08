extends Area2D

@export var _speed = 100
var velocity: Vector2 = Vector2.ZERO

@onready var enclosure_zone: Rect2 = get_node("../AiField").get_rect() as Rect2
const ENCLOSURE_ZONE_PADDING: int = 40

var wander_angle: float = 0

const WANDER_RAND: float = 0.4
const WANDER_CIRCLE_RADIUS: int = 12
const AVOID_MULTIPLIER: int = 1


func _process(delta):
	velocity = Vector2.ZERO
	velocity += enclosure_steering() 
	velocity += avoid_fruits_steering() * AVOID_MULTIPLIER
	velocity += wander_steering() 
	print(avoid_fruits_steering())
	velocity = velocity.normalized() * delta * _speed

	position += velocity


func is_in_left(a: Vector2, b: Vector2, c: Vector2) -> bool:
	return (b.x - a.x)*(c.y-a.y) - (b.y-a.y)*(c.x-a.x) > 0

func avoid_fruits_steering() -> Vector2:
	var avoid_steering: Vector2 = Vector2.ZERO
	var total_danger: int = 0
	for fruit in Projectiles.spawned:
		if(!is_instance_valid(fruit)): continue
		var fruit_avoid_direction: Vector2 = Vector2.ZERO
		var orth_dir: int = -1 if is_in_left(fruit.global_position, fruit.direction + fruit.global_position, global_position) else 1
		fruit_avoid_direction = fruit.direction.orthogonal() * orth_dir
		
		var steer_strength: int = fruit.damage * (1000 / (position.distance_to(fruit.position)))
#		print("AAA", steer_strength)
		avoid_steering += fruit_avoid_direction * steer_strength
		total_danger += fruit.damage
	
	if avoid_steering != Vector2.ZERO: 
		wander_angle = lerp(wander_angle, avoid_steering.angle(), 0.2)
#	print(avoid_steering)
	return avoid_steering.normalized() * total_danger / 1000

func wander_steering() -> Vector2:
	wander_angle = randf_range(wander_angle - WANDER_RAND, wander_angle + WANDER_RAND)
	
	var vec_to_circle: Vector2 = velocity.normalized() * _speed
	var next_direction: Vector2 = vec_to_circle + Vector2(WANDER_CIRCLE_RADIUS, 0).rotated(wander_angle)
	
	return next_direction - velocity


func enclosure_steering() -> Vector2:
	var steer_direction: Vector2 = Vector2.ZERO
	
	if position.x < enclosure_zone.position.x + ENCLOSURE_ZONE_PADDING:
		steer_direction.x = 1
	elif position.x > enclosure_zone.position.x + enclosure_zone.size.x - ENCLOSURE_ZONE_PADDING:
		steer_direction.x -= 1
	if position.y < enclosure_zone.position.y + ENCLOSURE_ZONE_PADDING:
		steer_direction.y = 1
	elif position.y > enclosure_zone.position.y + enclosure_zone.size.y - ENCLOSURE_ZONE_PADDING:
		steer_direction.y -= 1
	
	steer_direction = steer_direction.normalized()
	
	if steer_direction != Vector2.ZERO:
		wander_angle = steer_direction.angle()
	
	return steer_direction * _speed
