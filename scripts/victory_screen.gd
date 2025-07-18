extends Control

@onready var grid_container: GridContainer = $GridContainer
@onready var result_label: Label = $MarginContainer5/Result
@onready var end_timer: Timer = $EndTimer
@onready var victory_jingle: AudioStreamPlayer = $VictoryJingle

const PLAYER_RESULT_SCENE := preload("res://scenes/color_score.tscn")

func _ready() -> void:
	print("VictoryScreen READY")
	print("Game.players (crudo): ", Game.players)
	print("Utils.Score: ", Utils.Score)
	call_deferred("_init_players")
	end_timer.timeout.connect(_on_end_timer_timeout)
	victory_jingle.play()

func _init_players() -> void:
	_render_victory_results()


func _render_victory_results() -> void:
	grid_container.columns = Game.players.size() 
	var max_score := -1
	var winners: Array = []

	for p in Game.players:
		var role: Statics.Role = p.role
		var role_name: String = Statics.get_role_name(role)
		var color: Color = get_role_color(role)
		var score: int = Utils.Score.get(role, 0)

		print("PlayerData role: ", role, " name: ", p.name, " score: ", score)

		if score > max_score:
			max_score = score
			winners = [role]
		elif score == max_score:
			winners.append(role)

		var result_ui = PLAYER_RESULT_SCENE.instantiate()
		result_ui.set_data(role_name, score, color)
		grid_container.add_child(result_ui)
		print("Child added: ", result_ui)

	# Mostrar resultado
	if winners.size() == 1:
		var winner_name = Statics.get_role_name(winners[0]).to_upper()
		result_label.text = "JUGADOR %s GANÓ" % winner_name
		result_label.label_settings.font_color = get_role_color(winners[0])
	else:
		result_label.text = "EMPATE"
		result_label.label_settings.font_color = Color.BLACK

func _on_end_timer_timeout() -> void:
	Lobby.go_to_lobby()

func get_role_color(role: Statics.Role) -> Color:
	match role:
		Statics.Role.GREEN:
			return Color(0, 1, 0)
		Statics.Role.BLUE:
			return Color(0, 0, 1)
		Statics.Role.RED:
			return Color(1, 0, 0)
		Statics.Role.YELLOW:
			return Color(1, 1, 0)
		_:
			return Color.WHITE
