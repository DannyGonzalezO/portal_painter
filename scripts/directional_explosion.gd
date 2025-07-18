extends Area2D

class_name DirectionalExplosion
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var paint_layer: TileMapLayer = null
var owner_id: int

#func _ready() -> void:
	#if paint_layer:
		#var tile_coords = paint_layer.local_to_map(global_position)
		#paint_layer.set_cell(0, tile_coords, 0, Vector2i(0, 0))

func _ready() -> void:
	var role = get_owner_role()
	match role:
		Statics.Role.GREEN:
			animated_sprite_2d.play("green")
		Statics.Role.BLUE:
			animated_sprite_2d.play("blue")
		Statics.Role.RED:
			animated_sprite_2d.play("red")
		Statics.Role.YELLOW:
			animated_sprite_2d.play("yellow")

func play_animation(animation_name: String):
	animated_sprite_2d.play(animation_name)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).die(paint_layer)

func _on_area_entered(area: Area2D) -> void:
	if area is Bomb:
		(area as Bomb).exploded_by_other()
		
func get_owner_role() -> Statics.Role:
	for p in Game.players:
		if p.id == owner_id:
			return p.role
	return Statics.Role.NONE
