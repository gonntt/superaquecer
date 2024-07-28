extends Node2D
class_name PopupUserName

@onready var time_label = $TimerLabel
@onready var timer = $Timer
@onready var input := %Input
@onready var janela := %Janela

var elapsed_time := 0


func _on_button_pressed() -> void:
	janela.show()
	input.grab_focus()
	input.clear()


func _ready():
	StaticVariables.player_time = total_time_elapsed(00, 00)
	timer.start()


func _on_timer_timeout() -> void:
	elapsed_time += 1
	var seconds := int(elapsed_time % 60)
	var minutes := int(elapsed_time / 60.0)
	time_label.text = total_time_elapsed(seconds, minutes)
	
	StaticVariables.timer_seconds = elapsed_time
	StaticVariables.player_time = total_time_elapsed(seconds, minutes)


func total_time_elapsed(_seconds, _minutes) -> String:
	return str(_minutes).pad_zeros(2) + ":" + str(_seconds).pad_zeros(2)
