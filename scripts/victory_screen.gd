extends Control
@onready var green_points: Label = $MarginContainer3/GreenPoints
@onready var blue_points: Label = $MarginContainer4/BluePoints
@onready var result: Label = $MarginContainer5/Result

func _ready() -> void:
	var gp = Utils.Score[2]
	var bp = Utils.Score[3]
	blue_points.label_settings.font_color = Color(0,0,1)
	blue_points.text = "%d Casillas"  %[bp]
	green_points.label_settings.font_color = Color(0,1,0)
	green_points.text = "%d Casillas" %[gp] 
	if gp > bp:
		result.text = "JUGADOR VERDE GANÓ"
		result.label_settings.font_color = Color(0,1,0)
	elif bp > gp:
		result.text = "JUGADOR AZUL GANÓ"
		result.label_settings.font_color = Color(0,0,1)
	elif gp == bp:
		result.text = "EMPATE"
		result.label_settings.font_color = Color(0,0,0)
