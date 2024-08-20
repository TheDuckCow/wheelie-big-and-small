extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("We hit a speed bump!")
	if body is not PlayerCar:
		return
	var car:PlayerCar = body
	if car.get_speed() > PlayerCar.MIN_SPEED:
		car.set_speed(PlayerCar.MIN_SPEED)
