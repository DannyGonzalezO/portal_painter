extends Resource

class_name PowerUpRes

enum PowerUpType {
	BOMB_UP,
	FIRE_UP,
	WALL_PASS
}

@export var type: PowerUpType
@export var texture: Texture
