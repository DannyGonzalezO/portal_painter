extends Node

class_name BombPlacementSystem



const tile_size = 16
var BOMB_SCENE = load("res://scenes/bomb.tscn")
var player: Player = null
var bombs_placed = 0
var explosion_size = 1

func _ready() -> void:
	player = get_parent()

@rpc("call_local")
func place_bomb_rpc(pos: Vector2):
	if bombs_placed == player.max_bombs_at_once:
		return
	
	var bomb = BOMB_SCENE.instantiate()
	bomb.position = pos
	bomb.explosion_size = explosion_size
	get_tree().root.add_child(bomb)
	bombs_placed += 1
	bomb.tree_exiting.connect(on_bomb_exploded)

func place_bomb():
	if bombs_placed == player.max_bombs_at_once:
		return
	
	var player_position = player.global_position
	print(player.position)
	var bomb_position = Vector2(
		round(player_position.x / tile_size) * tile_size,
		round(player_position.y / tile_size) * tile_size
	)
	print(bomb_position)
	# Colocar local
	place_bomb_rpc(bomb_position)

	# Sincronizar con todos (incluye host también)
	place_bomb_rpc.rpc(bomb_position)

	
func on_bomb_exploded():
	bombs_placed -= 1
