extends CharacterBody2D

class_name Player 

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycasts: Raycasts = $Raycasts
@onready var bomb_placement_system: BombPlacementSystem = $BombPlacementSystem
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var sync_timer: Timer = $SyncTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var last_non_zero_movement: Vector2 = Vector2.DOWN
@onready var power_up_system: Node = $PowerUpSystem


@export var movement_speed: float = 75
var max_bombs_at_once = 1

var movement: Vector2 = Vector2.ZERO
var tile_size: int = 16

func setup(player_data: Statics.PlayerData):
	set_multiplayer_authority(player_data.id, false)
	input_synchronizer.set_multiplayer_authority(player_data.id)

	if is_multiplayer_authority():
		sync_timer.timeout.connect(_on_sync)
		sync_timer.start()

func _process(delta: float) -> void:
	# Solo autoridad calcula movimiento
	if is_multiplayer_authority():
		var collisions = raycasts.check_collisions()
		
		if collisions.has(movement):
			movement = Vector2.ZERO  # Detener si hay colisión

		position += movement * delta * movement_speed

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
	
	if Input.is_action_pressed("bomb"):
		bomb_placement_system.place_bomb()

func die():
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


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is PowerUp:
		power_up_system.enable_power_up((area as PowerUp).type)
		area.queue_free()
