extends Node
@onready var players: Node2D = $Players
@export var player_scene: PackedScene
@onready var markers: Node2D = $Markers
@onready var game_timer: Timer = $GameTimer
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var paint_layer: TileMapLayer = $PaintLayer
@onready var brick_walls: Node = $BrickWalls
@onready var paint_bomb_main_theme: AudioStreamPlayer = $PaintBombMainTheme


const BRICK_SCENE = preload("res://scenes/brick_wall.tscn")
const START_X: int = -112
const END_X: int = 208
const START_Y: int = -64
const END_Y: int = 96
const STEP: int = 16

func is_fixed_wall(x: int, y: int) -> bool:
	# Fixed walls: Start at -96, -48, placed every 32px (skip every other tile)
	if x < -96 or x > 192 or y < -48 or y > 80:
		return false
	return (x - -96) % 32 == 0 and (y - -48) % 32 == 0

func spawn_bricks():
	for x in range(START_X, END_X + 1, STEP):
		for y in range(START_Y, END_Y + 1, STEP):
			if is_fixed_wall(x, y):
				continue
			# Optional: Skip player spawn positions (prevent spawn-kill)
			var pos = Vector2(x, y)
			var is_near_spawn = false
			for i in markers.get_child_count():
				if pos.distance_to(markers.get_child(i).global_position.snapped(Vector2(STEP, STEP))) < STEP * 2:
					is_near_spawn = true
					break
			if is_near_spawn:
				continue
			
			if randi() % 10 < 3: #Brick spawn chance
				continue
			var brick = BRICK_SCENE.instantiate()
			brick.global_position = pos

			# Randomly assign power-up (40% chance)
			if randi() % 10 < 4:
				brick.power_up = Utils.power_ups.keys().pick_random()

			brick_walls.add_child(brick,true)

func _ready() -> void:
	for i in Game.players.size():
		var player = Game.players[i]
		player.marker_id = i
		var player_inst = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.setup(player)
		player_inst.global_position = markers.get_child(i).global_position
		player_inst.paint_layer = paint_layer #Asignamos paint_layer
		game_timer.timeout.connect(_on_game_timer_timeout)
		if multiplayer.is_server():
			player_inst.death_requested.connect(_on_player_death_requested)
	#TODO: instanciar ladrillos
	if is_multiplayer_authority():
		spawn_bricks()
	paint_bomb_main_theme.play()
	
func _process(delta: float) -> void:
	var seconds = int(game_timer.time_left) % 60
	var minutes = int(game_timer.time_left) / 60
	time_label.text = "%02d:%02d" % [minutes, seconds] 

func _on_game_timer_timeout() -> void:
	go_to_victory.rpc()
	
func count_tiles_by_color() -> Dictionary:
	var counts := {}

	# Inicializa todos los roles posibles en 0
	for role in Statics.Role.values():
		if role != Statics.Role.NONE:
			counts[role] = 0

	# Contar celdas pintadas
	for cell in paint_layer.get_used_cells():
		var tile_id: int = paint_layer.get_cell_alternative_tile(cell)
		var role = get_role_from_tile_id(tile_id)

		if role == Statics.Role.NONE:
			continue

		counts[role] += 1

	print("Final score counts by role: ", counts)
	Utils.Score = counts
	return counts

func _on_player_death_requested(paint_layer: TileMapLayer, player_id: int) -> void:
	print("ACCEPT")
	var player_data = Game.get_player(player_id)
	kill_player.rpc(int(player_id))

@rpc("call_local", "reliable")
func kill_player(player_id: int) -> void:
	print("Killed")
	var player_node = players.get_node(str(player_id))
	if player_node:
		player_node.queue_free()
	
	var player_data = Game.get_player(player_id)
	#var player_index = Game.players.find(player_data)
	var respawn_timer = Timer.new()
	respawn_timer.one_shot = true
	respawn_timer.wait_time = 4.0
	add_child(respawn_timer)
	respawn_timer.timeout.connect(func():
		respawn_player(player_id)
		respawn_timer.queue_free()
	)
	respawn_timer.start()


func respawn_player(player_index) -> void:
	print("RESPAWN PLAYER")
	print(player_index)
	var player_data = Game.get_player(player_index)
	var new_player = player_scene.instantiate()
	new_player.paint_layer = paint_layer
	
	
	new_player.global_position = markers.get_child(player_data.marker_id).position
	await get_tree().physics_frame
	new_player.setup.call_deferred(player_data)
	players.add_child(new_player)
	if multiplayer.is_server():
		new_player.death_requested.connect(_on_player_death_requested)

func get_role_from_tile_id(tile_id: int) -> Statics.Role:
	match tile_id:
		0:
			return Statics.Role.YELLOW
		1:
			return Statics.Role.RED
		2:
			return Statics.Role.GREEN
		3:
			return Statics.Role.BLUE
		_:
			return Statics.Role.NONE

@rpc("any_peer","call_local","reliable")
func go_to_victory() -> void:
	var tiles_finales = count_tiles_by_color()
	get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")
