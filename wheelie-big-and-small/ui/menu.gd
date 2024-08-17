extends Control


@onready var start_btn  := %start_btn


func _ready() -> void:
	start_btn.grab_focus()


func _process(delta: float) -> void:
	pass


func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
