extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().change_scene_to_file("res://ui/menu.tscn")
