extends CharacterBody3D

@onready var speed := randf_range(5, 15)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity = Vector3(0, 0, -speed)
	move_and_slide()
