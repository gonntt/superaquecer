extends Node

@export var scene1_instance : Node2D
@export var scene2_instance : Node2D

func _ready():
	scene1_instance.instantiate()
	add_child(scene1_instance)

func go_to_scene2():
	# Pausar a cena 1
	scene1_instance.get_tree().paused = true
	scene1_instance.set_physics_process(false)

	scene2_instance.instantiate()
	add_child(scene2_instance)

func return_to_scene1():
	remove_child(scene2_instance)
	scene2_instance.queue_free()

	scene1_instance.get_tree().paused = false
	scene1_instance.set_physics_process(true)
