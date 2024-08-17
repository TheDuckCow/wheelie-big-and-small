extends Camera3D


@onready var rest_direction: Vector3 = transform.origin.normalized()
@onready var rest_unit_scaled: float = transform.origin.length()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player: PlayerCar = get_parent()
	var psize = player.get_target_size()
	
	# Logic: If the player is going the "rest speed",
	# then the position of the camera should be the same as we
	# see in the 3D view itself (ie unit vector * player size
	var target_pos: Vector3 = rest_direction * psize * rest_unit_scaled
	# Lerp it out to give it some smoothing, so it feels less rigid
	transform.origin = lerp(
		transform.origin,
		target_pos,
		delta * 2)
	
