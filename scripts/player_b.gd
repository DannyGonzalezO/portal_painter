extends Area2D

class_name Player 
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycasts: Raycasts = $Raycasts
@onready var bomb_placement_system: BombPlacementSystem = $BombPlacementSystem


@export var movement_speed: float = 75

var max_bombs_at_once = 1


var movement: Vector2 = Vector2.ZERO
var tile_size: int = 16


func _process(delta: float) -> void:
	var collisions = raycasts.check_collisions()
	
	if collisions.has(movement):
		return
	position += movement * delta * movement_speed

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("move_right"):
		if movement != Vector2.RIGHT:
			snap_to_grid("horizontal")
		movement = Vector2.RIGHT
		animated_sprite_2d.play("walk_right")
	elif Input.is_action_pressed("move_left"):
		if movement != Vector2.LEFT:
			snap_to_grid("horizontal")
		movement = Vector2.LEFT
		animated_sprite_2d.play("walk_left")
	elif Input.is_action_pressed("move_up"):
		if movement != Vector2.UP:
			snap_to_grid("vertical")
		movement = Vector2.UP
		animated_sprite_2d.play("walk_up")
	elif Input.is_action_pressed("move_down"):
		if movement != Vector2.DOWN:
			snap_to_grid("vertical")
		movement = Vector2.DOWN
		animated_sprite_2d.play("walk_down")
	elif Input.is_action_pressed("bomb"):
		bomb_placement_system.place_bomb()
	else:
		movement = Vector2.ZERO
		animated_sprite_2d.stop()

func die():
	print("DIE")

func snap_to_grid(axis: String) -> void:
	if axis == "horizontal":
		position.y = round(position.y / tile_size) * tile_size
	elif axis == "vertical":
		position.x = round(position.x / tile_size) * tile_size
