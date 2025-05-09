extends Node

class_name BombPlacementSystem



const tile_size = 16
var BOMB_SCENE = load("res://scenes/bomb.tscn")
var player: Player = null
var bombs_placed = 0
var explosion_size = 1

func _ready() -> void:
	player = get_parent()
	
@rpc("any_peer")
func request_bomb_placement(pos: Vector2):
	if is_multiplayer_authority():
		place_bomb_rpc(pos)
		place_bomb_rpc.rpc(pos)  # Reenvía a todos los clientes


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
	var bomb_position = Vector2(
		round(player_position.x / tile_size) * tile_size,
		round(player_position.y / tile_size) * tile_size
	)

	if is_multiplayer_authority():
		# Host lo coloca y lo sincroniza con todos
		place_bomb_rpc(bomb_position)
		place_bomb_rpc.rpc(bomb_position)
	else:
		# Cliente le pide al host que lo haga
		request_bomb_placement.rpc_id(1, bomb_position)
		
func on_bomb_exploded():
	bombs_placed -= 1
