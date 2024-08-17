extends Control

const MENU = "res://ui/menu.tscn"

func _ready() -> void:
	var res = get_tree().change_scene_to_file(MENU)
	assert(res == OK)
