extends Control

@onready var points_label: Label = $VBoxContainer/PointsLabel
@onready var role_label: Label = $VBoxContainer/RoleLabel

var role_name := ""
var points := 0
var color := Color.WHITE

func set_data(name: String, pts: int, col: Color) -> void:
	role_name = name
	points = pts
	color = col

func _ready() -> void:
	if role_label == null or points_label == null:
		push_error("Uno de los labels es null")
		return
	
	role_label.text = role_name
	role_label.label_settings.font_color = color
	
	points_label.text = "%d Casillas" % points
	points_label.label_settings.font_color = color
