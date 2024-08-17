extends Control

const MENU = "res://ui/menu.tscn"

func _ready() -> void:
	get_tree().change_scene_to_file(MENU)
