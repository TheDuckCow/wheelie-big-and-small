extends CanvasLayer

@onready var anim_player := $AnimationPlayer

func to_scene(scene_path: String) -> void:
	get_tree().paused = false
	anim_player.play("dissolve")
	if anim_player.is_playing():
		await anim_player.animation_finished
	var res = get_tree().change_scene_to_file(scene_path)
	print("change scene err: ", res)
	assert(res == OK)
	anim_player.play_backwards("dissolve")
