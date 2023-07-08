extends Area2D

@export var _speed = 70
var velocity: Vector2 = Vector2.ZERO

@export var enclosure_zone: Rect2 = Rect2(16, 16, 480, 256)

var wander_angle: float = 0

const WANDER_RAND: float = 0.8
const WANDER_CIRCLE_RADIUS: int = 2


func _process(delta):
	velocity = wander_steering() 
	
	var enc_steer = enclosure_steering()
	if enc_steer != Vector2.ZERO:
		velocity += enc_steer 
	
	velocity = velocity.normalized() * delta * _speed

	position += velocity


func wander_steering() -> Vector2:
	wander_angle = randf_range(wander_angle - WANDER_RAND, wander_angle + WANDER_RAND)
	
	var vec_to_circle: Vector2 = velocity.normalized() * _speed
	var next_direction: Vector2 = vec_to_circle + Vector2(WANDER_CIRCLE_RADIUS, 0).rotated(wander_angle)
	
	return next_direction - velocity


func enclosure_steering() -> Vector2:
	var steer_direction: Vector2 = Vector2.ZERO
	
	if position.x < enclosure_zone.position.x:
		steer_direction.x = 1
	elif position.x > enclosure_zone.position.x + enclosure_zone.size.x:
		steer_direction.x -= 1
	if position.y < enclosure_zone.position.y:
		steer_direction.y = 1
	elif position.y > enclosure_zone.position.y + enclosure_zone.size.y:
		steer_direction.y -= 1
	
	steer_direction = steer_direction.normalized()
	
	if steer_direction != Vector2.ZERO:
		wander_angle = steer_direction.angle()
	
	return steer_direction * _speed
