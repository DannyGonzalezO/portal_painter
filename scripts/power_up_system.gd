extends Node
class_name PowerUpSystem

var player: Player
@onready var bomb_placement_system: BombPlacementSystem = $"../BombPlacementSystem"

func _ready() -> void:
	player = get_parent()
	print("PowerUpSystem ready for player: ", player.name) # Debug

func enable_power_up(power_up_type: Utils.PowerUpType):
	print(">> enable_power_up llamado con: ", power_up_type)
	match power_up_type:
		Utils.PowerUpType.BOMB_UP:
			player.max_bombs_at_once += 1
			print(">> Aumentando bombas a: ", player.max_bombs_at_once)
			player.update_max_bombs.rpc(player.max_bombs_at_once)


			
		Utils.PowerUpType.FIRE_UP:
			bomb_placement_system.explosion_size += 1
			# Si necesitas sincronizar explosion_size:
			bomb_placement_system.update_explosion_size.rpc(bomb_placement_system.explosion_size)
			
		Utils.PowerUpType.WALL_PASS:
			var raycast_nodes = get_tree().get_nodes_in_group("raycasts") as Array[RayCast2D]
			for raycast in raycast_nodes:
				raycast.set_collision_mask_value(3, false)
			# Si necesitas sincronizar wall pass:
			#player.enable_wall_pass.rpc()
