extends Control

signal on_restart_game

@onready var score_label := %score_label
@onready var default_focus_btn := %retry
@onready var new_record_label := %record


func _ready() -> void:
	if Data.current_score_msec == 0.0:
		score_label.text = "(no score)"
	else:
		score_label.text = "Score: %.1f m" % Data.run_distance_m
	
	if Data.was_new_record:
		new_record_label.show()
	else:
		new_record_label.hide()


func _unhandled_input(_event: InputEvent) -> void:
	var what_focus = get_viewport().gui_get_focus_owner()
	if not what_focus and Input.is_action_just_pressed("ui_accept"):
		restart_game()
		return
	
	# Grab focus if anything else happens
	var is_ui = _event.is_action_pressed("ui_cancel")
	is_ui = is_ui or _event.is_action_pressed("ui_right")
	is_ui = is_ui or _event.is_action_pressed("ui_left")
	is_ui = is_ui or _event.is_action_pressed("ui_up")
	is_ui = is_ui or _event.is_action_pressed("ui_down")
	is_ui = is_ui or _event.is_action_pressed("ui_focus_next")
	is_ui = is_ui or _event.is_action_pressed("ui_focus_prev")
	if is_ui:
		default_focus_btn.grab_focus()
	
	get_viewport().set_input_as_handled()


func restart_game() -> void:
	# SceneTransition.to_scene("res://scenes/game_scene.gd")
	get_tree().paused = false
	on_restart_game.emit()


func _on_retry_pressed() -> void:
	restart_game()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	SceneTransition.to_scene("res://ui/menu.tscn")
