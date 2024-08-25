extends Control


@onready var start_btn  := %start_btn
@onready var high_score_label := %high_score

func _ready() -> void:
	start_btn.grab_focus()
	if Data.high_score_m == 0:
		high_score_label.hide()
	else:
		high_score_label.show()
		high_score_label.text = "Record: %.1f" % Data.high_score_m


func _process(_delta: float) -> void:
	pass


func _on_start_btn_pressed() -> void:
	# get_tree().change_scene_to_file()
	SceneTransition.to_scene("res://scenes/game_scene.tscn")
