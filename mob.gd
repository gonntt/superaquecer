extends Node2D

signal died

func _on_area_2d_body_entered(_body):
	Saveloader.changed_scene = true
	died.emit()
