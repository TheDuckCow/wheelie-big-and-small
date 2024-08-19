extends Node3D

func _ready():
	randomize_position()

func randomize_position():
	var random_x = randi_range(-8, 8)
	self.position.x = random_x

func process_obstacle() -> void:
	Signals.emit_signal("run_ended", self)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerCar:
		process_obstacle()
