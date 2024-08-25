extends Control


@onready var start_btn  := %start_btn
@onready var score_row := %score_row
@onready var high_score_label := %high_score

func _ready() -> void:
	start_btn.grab_focus()
	if Data.high_score_m == 0:
		score_row.hide()
	else:
		score_row.show()
		high_score_label.text = "Record: %.1f" % Data.high_score_m


func _process(_delta: float) -> void:
	pass



func _on_start_btn_pressed() -> void:
	# get_tree().change_scene_to_file()
	SceneTransition.to_scene("res://scenes/game_scene.tscn")


func _on_delete_save_pressed() -> void:
	Data.reset_highscore()
	score_row.hide()
