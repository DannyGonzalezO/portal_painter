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
	paint_tile_at_position(global_position)

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

func paint_tile_at_position(world_position: Vector2) -> void:
	if paint_layer == null:
		push_warning("Paint layer is not set!")
		return
	var tile_coords = paint_layer.local_to_map(world_position)
	var player = Game.get_player(owner_id)
	var role = player.role
	var role_int = player.role
	if role_int == 1:
		paint_layer.set_cell(tile_coords, 0, Vector2i(0,0), 2)
	elif role_int == 2:
		paint_layer.set_cell(tile_coords, 0, Vector2i(0,0), 3)
	elif role_int == 3:
		paint_layer.set_cell(tile_coords, 0, Vector2i(0,0), 1)
	elif role_int == 4:
		paint_layer.set_cell(tile_coords, 0, Vector2i(0,0), 0)
		
	#paint_layer.set_cell(tile_coords, 0, Vector2i(0,0), 1)  #1=Rojo, 2=Verde, 3=Azul
