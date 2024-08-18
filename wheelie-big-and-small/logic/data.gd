## Data class for holding game state and run data,
## minimal logic, mostly data containers only.
extends Node


var current_score_msec: float = 0.0
var high_score_msec: float = 0.0


func format_time_msec(msec: float) -> String:
	return "%.2f s" % (msec / 1000.0)
