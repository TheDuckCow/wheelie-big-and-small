extends Node3D


func process_obstacle() -> void:
	Signals.emit.run_ended(self)
