extends CharacterBody3D
class_name PlayerCar

const LANE_CHANGE_SPEED = 30.0
const ACCELERATION := 10.0
const BRAKE := 5.0
const COAST_FAC := 0.5

# Used throughout game to reference the "rest" position in 3d editor,
# since the car will be made both larger and smaller
const REST_SPEED := 10.0

## Colliders and rest positions, which we'll move around as the car scales
@onready var col_bottom_center := $col_bottom_center
@onready var col_bottom_center_rest: Vector3 = col_bottom_center.position
@onready var col_front_center := $col_front_center
@onready var col_front_center_rest: Vector3 = col_front_center.position
@onready var col_front_left := $col_front_left
@onready var col_front_left_rest: Vector3 = col_front_left.position
@onready var col_front_right := $col_front_right
@onready var col_front_right_rest: Vector3 = col_front_right.position

@onready var mesh_root := $root


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
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
	
	# Dont' allow going backwards
	if velocity.z > 0:
		velocity.z = 0
	
	# Now assert the size of the player based on the speed
	set_size(delta)
	
	# Move the player
	move_and_slide()


## Generic function to calc speed, used in UI too
func get_speed() -> float:
	return -velocity.z


func get_target_size() -> float:
	var fwd_speed:float = get_speed()
	# Might wnat to change how we further remap the size here
	var apply_scale = clamp(fwd_speed / REST_SPEED, 0.1, 100.0)
	return apply_scale


func set_size(_delta) -> void:
	mesh_root.scale = Vector3.ONE * get_target_size()
	

func set_speed(input: float) -> void:
	velocity.z = -abs(input)
