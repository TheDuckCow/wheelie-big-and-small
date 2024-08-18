extends Node3D


func process_obstacle() -> void:
	Signals.emit_signal("run_ended", self)


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Body entered barrel: ", body)
	if body is PlayerCar:
		print("Is it player car?")
		process_obstacle()
