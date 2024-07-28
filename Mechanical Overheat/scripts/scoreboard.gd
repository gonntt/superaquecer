extends Control

@onready var rows := %Rows

var row_scene_preload := preload("res://scenes/data_row.tscn")

func _ready() -> void:
	create_new_data_row(StaticVariables.player_name, StaticVariables.player_time)
	create_new_data_row("Nome2", "00:01")

func create_new_data_row(username: String, time: String):
	var new_table_row := row_scene_preload.instantiate()
	rows.add_child(new_table_row)
	new_table_row.change_font_color()
	new_table_row.set_values(username, time)
