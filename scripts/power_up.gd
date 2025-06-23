extends Area2D

class_name PowerUp

@onready var sprite_2d: Sprite2D = $Sprite2D

var type: Utils.PowerUpType

func init(power_up: String):
	var power_up_res = Utils.power_ups[power_up]
	sprite_2d.texture = power_up_res.texture
	type = power_up_res.type
