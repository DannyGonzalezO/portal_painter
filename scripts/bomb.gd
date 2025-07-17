extends Area2D

class_name Bomb

const CENTRAL_EXPLOSION = preload("res://scenes/central_explosion.tscn")

var explosion_size = 1
var paint_layer: TileMapLayer = null
var owner_id: int

func explosion() -> void:
	if is_queued_for_deletion():
		return
	var explosion = CENTRAL_EXPLOSION.instantiate()
	if explosion == null:
		return
	explosion.position = position
	explosion.size = explosion_size
	explosion.owner_id = owner_id
	explosion.paint_layer = paint_layer
	get_tree().root.add_child(explosion)
	queue_free()

func _on_timer_timeout() -> void:
	if !is_inside_tree(): return
	if is_queued_for_deletion(): return 
	explosion()

func exploded_by_other() -> void:
	explosion()
