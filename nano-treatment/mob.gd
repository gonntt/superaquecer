extends Node2D

var dying := false

signal died

func _on_area_2d_body_entered(_body):
	dying = true
	died.emit()
