extends Sprite2D
const BLUE_BOMB_BETA = preload("res://resources/sprites/bombs/blueBomb.png")
const PINK_BOMB_BETA = preload("res://resources/sprites/bombs/pink bomb beta.png")

func setup(player_data: Statics.PlayerData):
	texture = 	PINK_BOMB_BETA if player_data.role == Statics.Role.ROLE_A else BLUE_BOMB_BETA
