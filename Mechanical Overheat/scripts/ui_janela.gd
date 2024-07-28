extends Control

@onready var timer: Timer = %Timer


func _on_input_text_submitted(new_text: String) -> void:
	timer.stop()
	print(new_text)
	StaticVariables.player_name = new_text
	get_parent().hide()
	call_deferred("change_scene")


func change_scene():
	get_tree().change_scene_to_file("res://scenes/scoreboard.tscn")
