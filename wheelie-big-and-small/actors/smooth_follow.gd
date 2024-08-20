extends SpringArm3D

@export var lerp_speed = 55.0
@export var target: Node3D
@export var offset = Vector3.ZERO

func _physics_process(delta):
	if !target:
		return
	
	var target_xform = target.global_transform.translated_local(offset)
	global_transform = global_transform.interpolate_with(target_xform, lerp_speed * delta)

	look_at(target.global_transform.origin, target.transform.basis.y)
