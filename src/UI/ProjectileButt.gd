extends Control

@export var projectile: String

@onready var butt = $Butt

var projectile_texture
var projectile_scene: String


func _ready():
	projectile_scene = "res://src/Projectiles/" + projectile + "/" + projectile + ".tscn"
	$Butt/Icon.texture = load("res://assets/fruits/" + projectile + ".png")
	projectile_texture = load("res://assets/fruits/" + projectile + "-black.png")
