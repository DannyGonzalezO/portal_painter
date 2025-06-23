extends Node

enum PowerUpType {
	BOMB_UP,
	FIRE_UP,
	WALL_PASS
}

var Score: Dictionary

@export var power_ups: Dictionary [String, PowerUpRes]
