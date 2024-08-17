class_name Saveloader
extends Node2D

@onready var player = %Player

func save_game():
	var file = FileAccess.open("user://save.data", FileAccess.WRITE)
	
	var saved_data = {}
	
	saved_data["player_global_position"] = player.global_position
	
	file.store_var(saved_data)
	file.close()

func load_game():
	var file = FileAccess.open("user://save.data", FileAccess.READ)
	
	var saved_data = file.get_var()
	
	player.global_position = saved_data["player_global_position"]
	
	file.close()
	


func _on_mob_died():
	save_game()
	get_tree().call_deferred("change_scene_to_file", "res://empty_one.tscn")
