class_name Saveloader
extends Node2D

@onready var player = %Player
static var changed_scene

func _ready() -> void:
	if changed_scene:
		load_game()
		changed_scene = false

func save_game():
	var file = FileAccess.open("user://save.data", FileAccess.WRITE)
	
	var saved_data = {}
	
	saved_data["player_global_position"] = player.global_position
	
	for mob in get_tree().get_nodes_in_group("Mob"):
		saved_data["mob_global_position"] = mob.global_position
	
	file.store_var(saved_data)
	file.close()

func load_game():
	var file = FileAccess.open("user://save.data", FileAccess.READ)
	
	var saved_data = file.get_var()
	
	player.global_position = saved_data["player_global_position"]
	
	for mob in get_tree().get_nodes_in_group("Mob"):
		mob.get_parent().remove_child(mob)
		mob.queue_free()
	
	file.close()
	


func _on_mob_died():
	save_game()
	get_tree().call_deferred("change_scene_to_file", "res://empty_one.tscn")
