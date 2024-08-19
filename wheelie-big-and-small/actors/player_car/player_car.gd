extends CharacterBody3D
class_name PlayerCar

const LANE_CHANGE_SPEED = 30.0
const ACCELERATION := 10.0
const BRAKE := 5.0
const COAST_FAC := 0.5
const MAX_SPEED := 120.0  # Maximum speed

# Used throughout game to reference the "rest" position in 3d editor,
# since the car will be made both larger and smaller
const REST_SPEED := 10.0
const SCALE_SMOOTHING := 3.0 # smoothness of the scaling


var target_scale: float = 1.0
@onready var player_car = $"."


func _physics_process(delta: float) -> void:
	
	if global_transform.origin.y < 0:
		Signals.run_ended.emit(self)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# TODO: ensure the player is explicitly following along
	# the road lanes with forward, not just "forward".
	# Probably need to define a lane with offset
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var xfac: float = get_target_size() * LANE_CHANGE_SPEED
	if direction:
		velocity.x = lerp(velocity.x, direction.x * xfac, delta)
		velocity.z += direction.z * ACCELERATION * delta
	else:
		velocity.x = move_toward(velocity.x, 0, xfac * 1.5 * delta)
		velocity.z = move_toward(velocity.z, 0, COAST_FAC * delta)
	
	# Prevent going backwards
	if velocity.z > 0:
		velocity.z = 0

	# Clamp the speed to the maximum allowed speed
	velocity.z = max(velocity.z, -MAX_SPEED)
	
	# Now assert the size of the player based on the speed
	set_size(delta)
	
	# Move the player
	move_and_slide()

## Generic function to calc speed, used in UI too
func get_speed() -> float:
	return -velocity.z

func get_target_size() -> float:
	var fwd_speed:float = get_speed()
	# Might want to change how we further remap the size here
	var apply_scale = clamp(fwd_speed / REST_SPEED, 0.1, 100.0)
	return apply_scale

func set_size(delta: float) -> void:
	var current_scale = player_car.scale.x
	target_scale = get_target_size()
	var new_scale = lerp(current_scale, target_scale, SCALE_SMOOTHING * delta)
	player_car.scale = Vector3(new_scale, new_scale, new_scale)

func set_speed(input: float) -> void:
	velocity.z = -abs(input)
