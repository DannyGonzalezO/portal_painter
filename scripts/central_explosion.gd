extends Area2D

class_name CentralExplosion
@onready var explosion_sound: AudioStreamPlayer = $RetroWeaponGunLoFi03
@onready var raycasts: Array[RayCast2D] = [
	$RayCasts/RayCastUp,
	$RayCasts/RayCastRight,
	$RayCasts/RayCastDown,
	$RayCasts/RayCastLeft
]

#Explosion size in all directions
var size = 1
var tile_size = 16
var paint_layer: TileMapLayer = null
var owner_id: int


var animation_names: Array[String] = ["up", "right", "down", "left"]
var animation_directions: Array[Vector2] = [
	Vector2(0,-tile_size),
	Vector2(tile_size, 0),
	Vector2(0, tile_size),
	Vector2(-tile_size, 0)
]

const DIRECTIONAL_EXPLOSION = preload("res://scenes/directional_explosion.tscn")

func _ready() -> void:
	check_raycasts()

func check_raycasts():
	for i in raycasts.size():
		check_raycast_for_direction(animation_names[i], raycasts[i], animation_directions[i])


func check_raycast_for_direction(animation_name: String, raycast: RayCast2D, animation_direction: Vector2):
	raycast.target_position = raycast.target_position * size
	raycast.force_raycast_update()
	if !raycast.is_colliding():
		create_explosion_for_size(size, animation_name, animation_direction)
	else:
		var size_of_explosion = calculate_size_of_explosion(raycast)
		var collider = raycast.get_collider()
		if size_of_explosion != null:
			create_explosion_for_size(size_of_explosion, animation_name, animation_direction)
		execute_explosion_collision(collider)

func create_explosion_for_size(size: int, animation_name: String, animation_position: Vector2):
	for i in size:
		if i < size - 1:
			#Create middle animations until last tile
			create_explosion_animation_slice("%s_middle" % animation_name, animation_position * (i+1))
		else:
			create_explosion_animation_slice("%s_end" % animation_name, animation_position * (i+1))

func create_explosion_animation_slice(animation_name: String, animation_position: Vector2):
	explosion_sound.play()
	var directional_explosion = DIRECTIONAL_EXPLOSION.instantiate()
	directional_explosion.position = animation_position
	add_child(directional_explosion)
	directional_explosion.play_animation(animation_name)

	# Paint the tile at this explosion position
	paint_tile_at_position(global_position)
	paint_tile_at_position(global_position + animation_position)

	
func calculate_size_of_explosion(raycast: RayCast2D):
	var collider = raycast.get_collider()
	if collider is TileMapLayer:
		var collision_point = raycast.get_collision_point()
		
		var distance_to_collider = raycast.global_position.distance_to(collision_point)
		var size_of_explosion_before_collider = max(roundi(absf(distance_to_collider) / tile_size - 1), 0)
		return size_of_explosion_before_collider
		
func execute_explosion_collision(collider: Object):
	if collider is BrickWall:
		(collider as BrickWall).destroy()

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

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).die(paint_layer) #TODO Pasar argumento owner id
