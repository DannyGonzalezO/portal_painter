extends Camera2D

@export var node_to_follow: Node2D

var offset_camera_x = 32

var initial_x: float
func _ready() -> void:
	initial_x = (get_viewport_rect().size.x / 2) / zoom.x - offset_camera_x

func _process(delta:float) -> void:
	return
	#position.x = node_to_follow.position.x + initial_x
