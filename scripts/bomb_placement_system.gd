extends Node

class_name BombPlacementSystem


@onready var put_sound: AudioStreamPlayer = $"../PutSound"
const tile_size = 16
var BOMB_SCENE = load("res://scenes/bomb.tscn")
var player: Player = null
var bombs_placed = 0
var explosion_size = 1

func _ready() -> void:
	player = get_parent()
	
@rpc("any_peer", "reliable")
func request_bomb_placement(pos: Vector2):
	if is_multiplayer_authority():
		place_bomb_rpc.rpc(pos)

@rpc("call_local")
func place_bomb_rpc(pos: Vector2):
	_spawn_bomb(pos)

func place_bomb():
	var player_position = player.global_position
	var bomb_position = Vector2(
		round(player_position.x / tile_size) * tile_size,
		round(player_position.y / tile_size) * tile_size
	)

	print("Attempting to place bomb. Current bombs: ", bombs_placed, "/", player.max_bombs_at_once) # Debug
	
	if is_multiplayer_authority():
		place_bomb_rpc.rpc(bomb_position)
	else:
		request_bomb_placement.rpc_id(1, bomb_position)

func _spawn_bomb(pos: Vector2):
	if bombs_placed >= player.max_bombs_at_once:
		if multiplayer.get_unique_id() == 1:
			print("Host: Cannot place bomb - limit reached") # Debug
		else:
			print("Client: Cannot place bomb - limit reached")
		return
	if multiplayer.get_unique_id() == 1:
		print("Host: max bombs allowed: ", player.max_bombs_at_once)
	else:
		print("Client: max bombs allowed: ", player.max_bombs_at_once)
	put_sound.play()
	var bomb = BOMB_SCENE.instantiate()
	bomb.paint_layer = get_node("/root/Node/PaintLayer") # Or $PaintLayer if called from Main.gd directly
	bomb.position = pos
	bomb.explosion_size = explosion_size
	bomb.owner_id = player.get_multiplayer_authority()
	get_tree().root.add_child(bomb)
	bombs_placed += 1
	if multiplayer.get_unique_id() == 1:
		print("Host: Bomb placed. Total: ", bombs_placed) # Debug
	else:
		print("Client: Bomb placed. Total: ", bombs_placed) 
	bomb.tree_exiting.connect(on_bomb_exploded.bind())

func on_bomb_exploded():
	bombs_placed -= 1
	print("Bomb exploded. Remaining: ", bombs_placed) # Debug
	
@rpc("any_peer", "call_local", "reliable")
func update_explosion_size(new_max: int):
	explosion_size = new_max
	print("Max bombs updated to: ", explosion_size) # Debug
