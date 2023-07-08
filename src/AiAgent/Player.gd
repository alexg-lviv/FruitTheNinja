extends Area2D

@export var _speed = 100
var velocity: Vector2 = Vector2.ZERO

@onready var enclosure_zone: Rect2 = get_node("../AiField").get_rect() as Rect2
const ENCLOSURE_ZONE_PADDING: int = 40

var wander_angle: float = 0
var enclosure_steer_direction: Vector2 = Vector2.ZERO
var do_enclosure_steer: bool = false

const WANDER_RAND: float = 0.1
const WANDER_CIRCLE_RADIUS: int = 4
const AVOID_MULTIPLIER: int = 1
const ENCLOSURE_MUL: int = 10

@onready var tween
@onready var EnclosureTimer: Timer = get_node("EnclosureTimer") as Timer
@onready var DashTimer: Timer = get_node("DashTimer") as Timer
@onready var DashCooldown: Timer = get_node("DashCooldown") as Timer

var in_dash: bool = false
var can_dash: bool = true
var dash_speed: int = _speed * 15
var dash_direction: Vector2 = Vector2.ZERO
@export var dash_time = 0.12

func _process(delta):
	if(handle_dash()):
		position += dash_direction * dash_speed * delta
		clamp(position, enclosure_zone.position, enclosure_zone.position + enclosure_zone.size)
	else:
		velocity = Vector2.ZERO
		velocity += avoid_fruits_steering() * AVOID_MULTIPLIER
		if(!do_enclosure_steer):
			enclosure_steer_direction = enclosure_steering()
		if(do_enclosure_steer):
			velocity = enclosure_steer_direction
		velocity += wander_steering() 
		velocity = velocity.normalized() * delta * _speed

		position += velocity


func is_in_left(a: Vector2, b: Vector2, c: Vector2) -> bool:
	return (b.x - a.x)*(c.y-a.y) - (b.y-a.y)*(c.x-a.x) > 0

func handle_dash() -> bool:
	if(!can_dash and !in_dash): return false
	if(in_dash): return true
	for fruit in Projectiles.spawned:
		if(!is_instance_valid(fruit) or global_position.distance_to(fruit.global_position) > 150): continue
		in_dash = true
		can_dash = false
		dash_direction = position.direction_to(fruit.position)
		DashTimer.start(dash_time)
		return true	
	return false


func avoid_fruits_steering() -> Vector2:
	var avoid_steering: Vector2 = Vector2.ZERO
	var total_danger: int = 0
	for fruit in Projectiles.spawned:
		if(!is_instance_valid(fruit) or position.distance_to(fruit.position) > 200): continue
		var fruit_avoid_direction: Vector2 = Vector2.ZERO
		var orth_dir: int = -1 if is_in_left(fruit.global_position, fruit.direction + fruit.global_position, global_position) else 1
		fruit_avoid_direction = (fruit.direction.orthogonal() * orth_dir + fruit.direction * 0.4).normalized()
		var steer_strength: int = fruit.damage * (1000 / (position.distance_to(fruit.position)))
		avoid_steering += fruit_avoid_direction * steer_strength
		total_danger += fruit.damage
	
#	if avoid_steering != Vector2.ZERO: 
#		wander_angle = lerp(wander_angle, avoid_steering.angle(), 0.2)
	return avoid_steering / 100.

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
		do_enclosure_steer = true
		enclosure_steer_direction = steer_direction
		EnclosureTimer.start()
	return steer_direction


func _on_enclosure_timer_timeout():
	enclosure_steer_direction = Vector2.ZERO
	do_enclosure_steer = false

func get_damaged(damage: int):
	Signals.emit_signal("camera_shake_requested", 8.0, 0.7)
	Signals.emit_signal("frame_freeze_requested", 40)
	$AnimationPlayer.play("damage")

	
func _on_area_entered(area):
	if(!in_dash): get_damaged(area.damage)
	if in_dash:
		Signals.emit_signal("camera_shake_requested", 8.0, 0.4)
		Signals.emit_signal("frame_freeze_requested", 20)
	area.die()

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_dash_timer_timeout():
	in_dash = false
	DashCooldown.start()
