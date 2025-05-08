extends Node

class_name PowerUpSystem

var player: Player

@onready var bomb_placement_system: BombPlacementSystem = $"../BombPlacementSystem"

func _ready() -> void:
	player = get_parent()

func enable_power_up(power_up_type: Utils.PowerUpType):
	match power_up_type:
		Utils.PowerUpType.BOMB_UP:
			player.max_bombs_at_once += 1
		Utils.PowerUpType.FIRE_UP:
			bomb_placement_system.explosion_size += 1
		Utils.PowerUpType.WALL_PASS:
			var raycast_nodes = get_tree().get_nodes_in_group("raycasts") as Array[RayCast2D]
			for raycast in raycast_nodes:
				raycast.set_collision_mask_value(3,false)
