extends Node2D
class_name PopupUserName

@onready var time_label = $TimerLabel
@onready var timer = $Timer
@onready var input := %Input
@onready var janela := %Janela

static var elapsed_time := 0
static var player_time := ""

func _on_button_pressed() -> void:
	popup_initializer()

func _ready():
	popup_initializer()

func popup_initializer():
	player_time = total_time_elapsed(00, 00)
	elapsed_time = 0
	timer.start()
	time_label.text = "00:00"
	janela.show()
	input.grab_focus()
	input.clear()

func _on_timer_timeout() -> void:
	elapsed_time += 1
	var seconds := int(elapsed_time % 60)
	var minutes := int(elapsed_time / 60.0)
	time_label.text = total_time_elapsed(seconds, minutes)
	player_time = total_time_elapsed(seconds, minutes)


func total_time_elapsed(_seconds, _minutes) -> String:
	return str(_minutes).pad_zeros(2) + ":" + str(_seconds).pad_zeros(2)
