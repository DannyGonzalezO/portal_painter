extends Node
@onready var players: Node2D = $Players
@export var player_scene: PackedScene
@onready var markers: Node2D = $Markers
@onready var game_timer: Timer = $GameTimer
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var paint_layer: TileMapLayer = $PaintLayer


func _ready() -> void:
	for i in Game.players.size():
		var player = Game.players[i]
		var player_inst = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.setup(player)
		player_inst.global_position = markers.get_child(i).global_position
		game_timer.timeout.connect(_on_game_timer_timeout)
		
func _process(delta: float) -> void:
	var seconds = int(game_timer.time_left) % 60
	var minutes = int(game_timer.time_left) / 60
	time_label.text = "%02d:%02d" % [minutes, seconds] 

func _on_game_timer_timeout() -> void:
	go_to_victory.rpc()
	
func count_tiles_by_color() -> Dictionary:
	var counts := {}
	for x in paint_layer.get_used_cells():
		var atlas_coords = paint_layer.get_cell_alternative_tile(x)
		if atlas_coords in counts:
			counts[atlas_coords] += 1
		else:
			counts[atlas_coords] = 1
	print(counts)
	Utils.Score = counts
	return counts

@rpc("any_peer","call_local","reliable")
func go_to_victory() -> void:
	var tiles_finales = count_tiles_by_color()
	get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")
