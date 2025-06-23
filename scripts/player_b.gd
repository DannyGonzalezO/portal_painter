extends CharacterBody2D

class_name Player 

#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycasts: Raycasts = $Raycasts
@onready var bomb_placement_system: BombPlacementSystem = $BombPlacementSystem
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var sync_timer: Timer = $SyncTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var last_non_zero_movement: Vector2 = Vector2.DOWN
@onready var power_up_system: Node = $PowerUpSystem

@export var paint_layer: TileMapLayer
@export var movement_speed: float = 75
var max_bombs_at_once = 1

var movement: Vector2 = Vector2.ZERO
var tile_size: int = 16
var player_source_id : int

func _ready():
	await get_tree().create_timer(0.01).timeout
	player_source_id = 2 if get_multiplayer_authority() == 1 else 3

func setup(player_data: Statics.PlayerData):
	set_multiplayer_authority(player_data.id, false)
	name = str(player_data.id)
	input_synchronizer.set_multiplayer_authority(player_data.id)

	if is_multiplayer_authority():
		sync_timer.timeout.connect(_on_sync)
		sync_timer.start()

func _process(delta: float) -> void:
	# Solo autoridad calcula movimiento
	if is_multiplayer_authority():
		#Sistema de velocidades
		var tile_pos = paint_layer.local_to_map(global_position)
		var tile_data = paint_layer.get_cell_alternative_tile(tile_pos) #0,tile_pos
		#print(tile_data)
		#print(get_multiplayer_authority())
		var speed_multiplier := 1.0

		if tile_data == player_source_id:
			speed_multiplier = 1.5  # On own paint
		elif tile_data in [2, 3] and tile_data != player_source_id:
			speed_multiplier = 0.5  # On enemy paint
		else:
			speed_multiplier = 1.0  # Unpainted or neutral

		var effective_speed = movement_speed * speed_multiplier
		
		
		var collisions = raycasts.check_collisions()
		
		if collisions.has(movement):
			movement = Vector2.ZERO  # Detener si hay colisión
			
		#Usar effective_speed
		
		position += movement * delta * effective_speed

	# Animaciones sincronizadas para todos (tanto autoridad como clientes)
	if movement != Vector2.ZERO:
		last_non_zero_movement = movement

		if movement == Vector2.RIGHT:
			playback.travel("walksRight")
		elif movement == Vector2.LEFT:
			playback.travel("walksLeft")
		elif movement == Vector2.UP:
			playback.travel("walksBack")
		elif movement == Vector2.DOWN:
			playback.travel("walksFront")
	else:
		# Elegir idle según última dirección
		if last_non_zero_movement == Vector2.RIGHT:
			playback.travel("idleRight")
		elif last_non_zero_movement == Vector2.LEFT:
			playback.travel("idleLeft")
		elif last_non_zero_movement == Vector2.UP:
			playback.travel("idleback")
		elif last_non_zero_movement == Vector2.DOWN:
			playback.travel("idle")

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if Input.is_action_pressed("move_right"):
		if movement != Vector2.RIGHT:
			snap_to_grid("horizontal")
		movement = Vector2.RIGHT
	elif Input.is_action_pressed("move_left"):
		if movement != Vector2.LEFT:
			snap_to_grid("horizontal")
		movement = Vector2.LEFT
	elif Input.is_action_pressed("move_up"):
		if movement != Vector2.UP:
			snap_to_grid("vertical")
		movement = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		if movement != Vector2.DOWN:
			snap_to_grid("vertical")
		movement = Vector2.DOWN
	else:
		movement = Vector2.ZERO
	
	if Input.is_action_just_pressed("bomb"):
		bomb_placement_system.place_bomb()



@rpc("any_peer", "call_remote")
func place_bomb_request():
	if is_multiplayer_authority():
		bomb_placement_system.place_bomb()


func die(): #TODO Pasar un argumento desde la explosion
	print("DIE")

func snap_to_grid(axis: String) -> void:
	if axis == "horizontal":
		position.y = round(position.y / tile_size) * tile_size
	elif axis == "vertical":
		position.x = round(position.x / tile_size) * tile_size

@rpc("unreliable_ordered")
func send_data(pos: Vector2, mov: Vector2) -> void:
	position = lerp(position, pos, 1)

	# Actualizar la dirección localmente (esto es lo que faltaba)
	movement = mov

	# Elegir animación correcta
	if mov != Vector2.ZERO:
		last_non_zero_movement = mov

		if mov == Vector2.RIGHT:
			playback.travel("walksRight")
		elif mov == Vector2.LEFT:
			playback.travel("walksLeft")
		elif mov == Vector2.UP:
			playback.travel("walksBack")
		elif mov == Vector2.DOWN:
			playback.travel("walksFront")
	else:
		if last_non_zero_movement == Vector2.RIGHT:
			playback.travel("idleRight")
		elif last_non_zero_movement == Vector2.LEFT:
			playback.travel("idleLeft")
		elif last_non_zero_movement == Vector2.UP:
			playback.travel("idleBack")
		elif last_non_zero_movement == Vector2.DOWN:
			playback.travel("idle")


func _on_sync() -> void:
	if is_multiplayer_authority():
		send_data.rpc(position, movement)

@rpc("any_peer", "call_remote")
func request_power_up(power_up_type: Utils.PowerUpType) -> void:
	if is_multiplayer_authority():
		power_up_system.enable_power_up(power_up_type)
		# También aplica localmente al host
		if multiplayer.get_unique_id() == multiplayer.get_remote_sender_id():
			power_up_system.enable_power_up(power_up_type)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is PowerUp:
		request_power_up.rpc((area as PowerUp).type)
		area.queue_free()
		
@rpc("authority", "call_local", "reliable")
func update_max_bombs(new_max: int):
	max_bombs_at_once = new_max
	print("Max bombs updated to: ", max_bombs_at_once) # Debug
	
