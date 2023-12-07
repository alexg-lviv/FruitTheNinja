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
@onready var StunCoolDown: Timer = get_node("StunCooldown") as Timer
@onready var Progress: TextureProgressBar = get_node("ProgressBar")

var current_trail: Trail

var in_dash: bool = false
var can_dash: bool = true
var is_stunned: bool = false
var dash_speed: int = _speed * 15
var dash_direction: Vector2 = Vector2.ZERO
@export var dash_time = 0.12
@export var dash_cooldown: float = 5.

var prev_pos: Vector2 = Vector2.ZERO

var curr_direction = Vector2.ZERO

# Logging data
var fruits_cut_this_frame: int = 0
var got_bonked_this_frame: int = 0
var is_on_board: bool = true


func _ready():
	Progress.max_value = dash_cooldown

func log_data():
	Logger.log_ninja_data("speed", _speed)
	Logger.log_ninja_data("velocity", [velocity.x, velocity.y])
	Logger.log_ninja_data("global_position", [global_position.x, global_position.y])
	Logger.log_ninja_data("in_dash", in_dash)
	Logger.log_ninja_data("can_dash", can_dash)
	Logger.log_ninja_data("is_stunned", is_stunned)
	Logger.log_ninja_data("dash_cooldown_time", $DashCooldown.time_left)
	Logger.log_ninja_data("fruits_cut_this_frame", fruits_cut_this_frame)
	Logger.log_ninja_data("got_bonked_this_frame", got_bonked_this_frame)
	Logger.log_ninja_data("is_on_board", is_on_board)

func _physics_process(delta):
	log_data()
	fruits_cut_this_frame = 0
	got_bonked_this_frame = 0

func _process(delta):
	if (DashCooldown.time_left - 1.) <= 0.:
		Progress.visible = false
	else:
		Progress.visible = true
		Progress.value = DashCooldown.time_left - 1.
	if(handle_dash() && !is_stunned):
		position += dash_direction * dash_speed * delta
		position = clamp(position, enclosure_zone.position, enclosure_zone.position + enclosure_zone.size)
		$Sprite2D.rotation = dash_direction.angle() + deg_to_rad(270)
		curr_direction = dash_direction
	elif (!is_stunned):
		velocity = Vector2.ZERO
		velocity += avoid_fruits_steering() * AVOID_MULTIPLIER
		if(!do_enclosure_steer):
			enclosure_steer_direction = enclosure_steering()
		if(do_enclosure_steer):
			velocity = enclosure_steer_direction
		velocity += wander_steering() 
		velocity = velocity.normalized() * delta * _speed
#		$Sprite2D.rotation = velocity.angle() + deg_to_rad(270)
		position += velocity
		curr_direction = velocity


func is_in_left(a: Vector2, b: Vector2, c: Vector2) -> bool:
	return (b.x - a.x)*(c.y-a.y) - (b.y-a.y)*(c.x-a.x) > 0

func handle_dash() -> bool:
	if(!can_dash and !in_dash): return false
	if(in_dash): return true
	
	for fruit in Projectiles.spawned:
		if(!is_instance_valid(fruit) or fruit.is_dead or global_position.distance_to(fruit.global_position) > 150): continue
		$DashSound.play()
		in_dash = true
		can_dash = false
		dash_direction = position.direction_to(fruit.position)
		DashTimer.start(dash_time)
		make_trail()
		return true	
	return false


func avoid_fruits_steering() -> Vector2:
	var avoid_steering: Vector2 = Vector2.ZERO
	var total_danger: int = 0
	for fruit in Projectiles.spawned:
		if(!is_instance_valid(fruit) or fruit.is_dead or position.distance_to(fruit.position) > 200): continue
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
	
	# Loggog data
	if (position.x < enclosure_zone.position.x - ENCLOSURE_ZONE_PADDING) || \
		(position.x > enclosure_zone.position.x + enclosure_zone.size.x + ENCLOSURE_ZONE_PADDING) || \
		(position.y < enclosure_zone.position.y - ENCLOSURE_ZONE_PADDING) || \
		(position.y > enclosure_zone.position.y + enclosure_zone.size.y + ENCLOSURE_ZONE_PADDING):
		is_on_board = false
	
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
	is_on_board = true

func get_damaged(damage: int, fruit):
	Signals.emit_signal("camera_shake_requested", 8.0, 0.7)
	Signals.emit_signal("frame_freeze_requested", 40)
	$AnimationPlayer.play("damage")
	Signals.emit_signal("fruit_hit", damage, fruit.position)
	
func _on_area_entered(area: Area2D):
	if area.is_dead: return
	if(!in_dash): 
		fruits_cut_this_frame += 1
		get_damaged(area.damage, area)
		if area.name == "Coconut":
			stun()
	if in_dash:
		got_bonked_this_frame += 1
		$SlashSound.play()
		Signals.emit_signal("camera_shake_requested", 8.0, 0.4)
		Signals.emit_signal("frame_freeze_requested", 20)
		area.slice()
	else:
		area.crash()


func _on_dash_cooldown_timeout():
	can_dash = true

func _on_dash_timer_timeout():
	$Sprite2D.rotation = 0
	in_dash = false
	current_trail.stop()
	current_trail = null
	DashCooldown.start(dash_cooldown)

func make_trail():
	if current_trail != null:
		current_trail.stop()
	current_trail = Trail.create()
	add_child(current_trail)

func stun():
	is_stunned = true
	$AnimationPlayer.play("stun")
	StunCoolDown.start()

func _on_stun_cooldown_timeout():
	is_stunned = false


func _on_timer_timeout():
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Sprite2D, "rotation", curr_direction.angle() + deg_to_rad(270), 0.5)
	prev_pos = global_position
