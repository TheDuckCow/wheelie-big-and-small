extends CharacterBody3D
class_name PlayerCar

const LANE_CHANGE_SPEED = 20.0
const ACCELERATION := 15.0
const BRAKE := 5.0
const COAST_FAC := 0.5
const MAX_SPEED := 40.0 
const MIN_SPEED := 10.0

# Used throughout game to reference the "rest" position in 3d editor,
# since the car will be made both larger and smaller
const REST_SPEED := 10.0
const SCALE_SMOOTHING := 7.5 # smoothness of the scaling


enum State {
	RUNNING,
	ENDED
}
var state:int = State.RUNNING

var target_scale: float = 1.0

@onready var player_car = $"."
@onready var animation_player := $AnimationPlayer

@onready var init_offset: float = global_transform.origin.z


func _ready() -> void:
	var res = Signals.run_ended.connect(on_run_ended)
	assert(res == OK)
	velocity.z = MIN_SPEED
	


func _physics_process(delta: float) -> void:
	# update progress:
	Data.run_distance_m = abs(global_transform.origin.z - init_offset)
	if abs(velocity.z) < MIN_SPEED - 1: # and Data.current_score_msec > 1000:
		Signals.run_ended.emit(self)
	
	if global_transform.origin.y < -0.1 and state == State.RUNNING:
		Signals.run_ended.emit(self)
		state = State.ENDED
		return
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
	
	#var xfac: float = get_target_size() * LANE_CHANGE_SPEED
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * LANE_CHANGE_SPEED, delta)
		velocity.z += direction.z * ACCELERATION * delta
	else:
		velocity.x = move_toward(velocity.x, 0, LANE_CHANGE_SPEED * 1.5 * delta)
		velocity.z = move_toward(velocity.z, 0, COAST_FAC * delta)
	
	# Prevent going backwards
	if velocity.z > -MIN_SPEED:
		velocity.z = -MIN_SPEED

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
	var fwd_speed: float = get_speed()
	
	# Speed thresholds
	var speed_threshold_1: float = 15.0
	var speed_threshold_2: float = 20.0
	var speed_threshold_3: float = 30.0
	
	# Cases for specific speed ranges
	if fwd_speed <= speed_threshold_1:
		return 0.075  # Keep the scale small
	
	if fwd_speed <= speed_threshold_2:
		# Linear interpolation between the small size and a slightly larger size
		return lerp(0.075, 0.15, (fwd_speed - speed_threshold_1) / (speed_threshold_2 - speed_threshold_1))
	
	if fwd_speed <= speed_threshold_3:
		# Logarithmic scaling for mid-range speeds but not to the max size
		var normalized_speed_mid = clamp((fwd_speed - speed_threshold_2) / (speed_threshold_3 - speed_threshold_2), 0.0, 1.0)
		var log_scale_mid = log(1.0 + 4.0 * normalized_speed_mid) / log(5.0)  # Smaller logarithmic growth
		return lerp(0.15, 1.0, log_scale_mid)
	
	# Logarithmic scaling for the higher speeds to the max size
	var normalized_speed_high = clamp((fwd_speed - speed_threshold_3) / (MAX_SPEED - speed_threshold_3), 0.0, 1.0)
	var log_scale_high = log(1.0 + 9.0 * normalized_speed_high) / log(10.0)  # Base 10 logarithm scaling
	return lerp(1.0, 2.5, log_scale_high)


func set_size(delta: float) -> void:
	if state == State.ENDED:
		return
	var current_scale = player_car.scale.x
	target_scale = get_target_size()
	var new_scale = lerp(current_scale, target_scale, SCALE_SMOOTHING * delta)
	player_car.scale = Vector3(new_scale, new_scale, new_scale)


func set_speed(input: float) -> void:
	velocity.z = -abs(input)


func on_run_ended(_obstacle) -> void:
	if state == State.ENDED:
		return
	state = State.ENDED
	animation_player.play("ended")
	
	Data.run_distance_m = abs(global_transform.origin.z - init_offset)
	Data.update_high_score()
