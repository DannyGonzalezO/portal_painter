extends CharacterBody2D

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Pivot/Sprite2D
@export var max_speed = 300
@export var acceleration = 600
@export var deceleration = 600
@export var bomb_scene: PackedScene
const BLUE_PAINTER_BETA = preload("res://resources/sprites/painters/blue painter beta.png")
const RED_PAINTER_BETA = preload("res://resources/sprites/painters/red painter beta.png")
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var pivot: Node2D = $Pivot
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer

func setup(player_data: Statics.PlayerData):
	label.text = player_data.name
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id, false)
	input_synchronizer.set_multiplayer_authority(player_data.id)
	sprite.texture = BLUE_PAINTER_BETA if player_data.role == Statics.Role.ROLE_A else RED_PAINTER_BETA

func _physics_process(delta: float) -> void:
	var move_input = input_synchronizer.move_input
	velocity = velocity.move_toward(move_input * max_speed, acceleration *delta)
	if move_input == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	#send_data.rpc(position, velocity)
	if input_synchronizer.bomb:
		input_synchronizer.bomb = false
		if is_multiplayer_authority():
			bomb.rpc_id(1, position)
	
	if move_input.x:
		pivot.scale.x = sign(move_input.x)
	
	move_and_slide()
	# animations
	if velocity:
		playback.travel("walk")
	else:
		playback.travel("idle")
			
	
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		pass
		
@rpc("unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.5)
	velocity = velocity.lerp(vel, 1)
	
@rpc("call_local")
func bomb(spawn_position: Vector2):
	var bomb_inst = bomb_scene.instantiate()
	bomb_inst.global_position = spawn_position
	multiplayer_spawner.add_child(bomb_inst, true)
	
