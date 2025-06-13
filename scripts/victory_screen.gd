extends Control
@onready var green_points: Label = $MarginContainer3/GreenPoints
@onready var blue_points: Label = $MarginContainer4/BluePoints
@onready var result: Label = $MarginContainer5/Result
@onready var end_timer: Timer = $EndTimer

func _ready() -> void:
	var gp = Utils.Score.get(2, 0)
	var bp = Utils.Score.get(3, 0)
	blue_points.label_settings.font_color = Color(0,0,1)
	blue_points.text = "%d Casillas"  %[bp]
	green_points.label_settings.font_color = Color(0,1,0)
	green_points.text = "%d Casillas" %[gp] 
	end_timer.timeout.connect(_on_end_timer_timeout)
	if gp > bp:
		result.text = "JUGADOR VERDE GANÓ"
		result.label_settings.font_color = Color(0,1,0)
	elif bp > gp:
		result.text = "JUGADOR AZUL GANÓ"
		result.label_settings.font_color = Color(0,0,1)
	elif gp == bp:
		result.text = "EMPATE"
		result.label_settings.font_color = Color(0,0,0)

func _on_end_timer_timeout() -> void:
	Lobby.go_to_lobby()
	
