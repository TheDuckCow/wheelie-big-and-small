## Data class for holding game state and run data,
## minimal logic, mostly data containers only.
extends Node


var current_score_msec: float = 0.0
var high_score_msec: float = 0.0
var checkpoint_timer_s: float = 0.0 
var run_distance_m: float = 0.0

var high_score_m: float = 0.0
var was_new_record: bool = false

func format_time_msec(msec: float) -> String:
	return "%.2f s" % (msec / 1000.0)

func update_high_score() -> void:
	if run_distance_m > high_score_m:
		was_new_record = true
		high_score_m = run_distance_m
	else:
		was_new_record = false
