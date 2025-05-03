extends Area2D

class_name Bomb

const CENTRAL_EXPLOSION = preload("res://scenes/central_explosion.tscn")

var explosion_size = 1

func _on_timer_timeout() -> void:
	var explosion = CENTRAL_EXPLOSION.instantiate()
	print(explosion)
	explosion.position = position
	explosion.size = explosion_size
	get_tree().root.add_child(explosion)
	queue_free()
