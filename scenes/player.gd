extends CharacterBody2D

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Pivot/Sprite2D
@export var max_speed = 400
@export var bomb_scene: PackedScene
const BLUE_PAINTER_BETA = preload("res://resources/sprites/painters/blue painter beta.png")
const RED_PAINTER_BETA = preload("res://resources/sprites/painters/red painter beta.png")
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var pivot: Node2D = $Pivot

func setup(player_data: Statics.PlayerData):
	label.text = player_data.name
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id, false)
	sprite.texture = BLUE_PAINTER_BETA if player_data.role == Statics.Role.ROLE_A else RED_PAINTER_BETA

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		position += max_speed * move_input * delta 
		send_data.rpc(position)
		if Input.is_action_just_pressed("bomb"):
			bomb.rpc_id(1, position)
		
		if move_input.x:
			pivot.scale.x = sign(move_input.x)
			
		# animations
		if move_input:
			playback.travel("walk")
		else:
			playback.travel("idle")
				

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		pass
		
@rpc("unreliable_ordered")
func send_data(pos: Vector2) -> void:
	position = lerp(position, pos, 0.5)
	
@rpc("call_local")
func bomb(spawn_position: Vector2):
	var bomb_inst = bomb_scene.instantiate()
	bomb_inst.global_position = spawn_position
	multiplayer_spawner.add_child(bomb_inst, true)
	
