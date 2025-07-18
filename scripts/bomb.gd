extends Area2D
class_name Bomb
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D



const CENTRAL_EXPLOSION = preload("res://scenes/central_explosion.tscn")


var explosion_size = 1
var paint_layer: TileMapLayer = null
var owner_id: int

func _ready() -> void:
	var role = get_owner_role()
	match role:
		Statics.Role.GREEN:
			animated_sprite.play("green")
		Statics.Role.BLUE:
			animated_sprite.play("blue")
		Statics.Role.RED:
			animated_sprite.play("red")
		Statics.Role.YELLOW:
			animated_sprite.play("yellow")

func explosion() -> void:
	if is_queued_for_deletion():
		return
	var explosion = CENTRAL_EXPLOSION.instantiate()
	if explosion == null:
		return
	explosion.position = position
	explosion.size = explosion_size
	explosion.owner_id = owner_id
	if is_instance_valid(paint_layer):
		explosion.paint_layer = paint_layer
	else:
		print("paint_layer inválido, se omite")
	get_tree().root.add_child(explosion)
	queue_free()

func _on_timer_timeout() -> void:
	if !is_inside_tree(): return
	if is_queued_for_deletion(): return 
	explosion()

func exploded_by_other() -> void:
	explosion()
	
func get_owner_role() -> Statics.Role:
	for p in Game.players:
		if p.id == owner_id:
			return p.role
	return Statics.Role.NONE
