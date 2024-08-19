extends Control


@onready var button2 = $Button2
@onready var button3 = $Button3
@onready var button4 = $Button4
@onready var button5 = $Button5

var correct_button

func _ready():
	correct_button = button3
	
	button2.connect("pressed", Callable(self, "_on_button_choice_pressed").bind(button2))
	button3.connect("pressed", Callable(self, "_on_button_choice_pressed").bind(button3))
	button4.connect("pressed", Callable(self, "_on_button_choice_pressed").bind(button4))
	button5.connect("pressed", Callable(self, "_on_button_choice_pressed").bind(button5))

func _on_button_choice_pressed(button):
	if button == correct_button:
		print("Correto!")
		button.text = "Correto!"
	else:
		print("Errado!")
		button.text = "Errado!"

func _on_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://main.tscn")
