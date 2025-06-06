extends Area2D

class_name DirectionalExplosion
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var paint_layer: TileMap = null

#func _ready() -> void:
	#if paint_layer:
		#var tile_coords = paint_layer.local_to_map(global_position)
		#paint_layer.set_cell(0, tile_coords, 0, Vector2i(0, 0))

func play_animation(animation_name: String):
	animated_sprite_2d.play(animation_name)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).die()

func _on_area_entered(area: Area2D) -> void:
	if area is Bomb:
		(area as Bomb).exploded_by_other()
