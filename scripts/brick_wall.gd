extends Area2D

class_name BrickWall
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const POWER_UP_SCENE = preload("res://scenes/power_up.tscn")

@export var power_up_res: PowerUpRes
@export var power_up: String

func destroy():
	animated_sprite_2d.play("destroy")



func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "destroy":
		if power_up:
			spawn_power_up()
		queue_free()

func spawn_power_up():
	print("Poder encontrado")
	var power_up_inst = POWER_UP_SCENE.instantiate()
	power_up_inst.global_position = global_position
	get_tree().root.add_child(power_up_inst)
	power_up_inst.init(power_up)
