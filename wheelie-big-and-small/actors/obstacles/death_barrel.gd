extends Node3D

func process_obstacle() -> void:
	Signals.emit_signal("run_ended", self)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerCar or body is NpcCar:
		process_obstacle()
