extends HBoxContainer

@onready var column_name := $Name
@onready var column_time := $Time
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_time := 0.0


func set_values(_name: String, _time: String) -> void:
	column_name.set_text(_name)
	column_time.set_text(_time)


func change_font_color():
	if (StaticVariables.timer_seconds >= 90):
		play_animation("bronze")
	elif (StaticVariables.timer_seconds > 40 and StaticVariables.timer_seconds < 90):
		play_animation("prata")
	elif (StaticVariables.timer_seconds > 20 and StaticVariables.timer_seconds <= 40):
		play_animation("ouro")
	else:
		play_animation("platina")

func play_animation(animation_name):
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)
