extends Node3D

@onready var road_manager: RoadManager= get_node("RoadManager")

@onready var time_start_msec := Time.get_ticks_msec()
var ran_once := false
var ended := false

func _ready() -> void:
	Signals.run_ended.connect(_run_ended)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process_physics(_delta: float) -> void:
	if not ran_once:
		# Workaround to ensure containers are built, not working properly in ready startup
		ran_once = true
		print("Game scene running: rebuild all containers")
		road_manager.rebuild_all_containers()
		print("Game scene ran: rebuild all containers")

## Returns the time in msec that this run has been running
func run_time_msec() -> float:
	if ended:
		return Data.current_score_msec
	var now := Time.get_ticks_msec()
	return (now - time_start_msec)


func run_time_s() -> float:
	return run_time_msec() / 1000


func _run_ended(source_node: Node) -> void:
	get_tree().paused = true
	print("The run was ended by: ", source_node)
	if ended:
		print("Was already ended...")
		return
	Data.current_score_msec = run_time_msec()
	ended = true # must assign this AFTER assigning the score above

	var ended_ui = preload("res://ui/end_run_ui.tscn").instantiate()
	add_child(ended_ui)
	var res = ended_ui.connect("on_restart_game", restart)
	assert(res == OK)


func restart() -> void:
	get_tree().paused = false
	var res = get_tree().reload_current_scene()
	assert(res == OK)
