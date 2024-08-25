## Data class for holding game state and run data,
## minimal logic, mostly data containers only.
extends Node

const SAVE_PATH:String = "user://wheelierscore.save"

var current_score_msec: float = 0.0
var high_score_msec: float = 0.0
var checkpoint_timer_s: float = 0.0 
var run_distance_m: float = 0.0

var high_score_m: float = 0.0
var was_new_record: bool = false

func _ready() -> void:
	high_score_m = read_highscore()


func format_time_msec(msec: float) -> String:
	return "%.2f s" % (msec / 1000.0)


func update_high_score() -> void:
	if run_distance_m > high_score_m:
		was_new_record = true
		high_score_m = run_distance_m
		save_highscore(high_score_m)
	else:
		was_new_record = false


func save_highscore(value: float) -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify({"highscore": value})
	save_file.store_line(json_string)
	save_file.close()


func read_highscore() -> float:
	var score:float = 0.0
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save path found for high score")
		return high_score_m
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var _data:Dictionary = json.get_data()
		var value = float(_data["highscore"])
		if value > 0.0:
			score = value
			print("Loaded high score: ", value)
	save_file.close()
	return score


func reset_highscore() -> void:
	high_score_m = 0.0
	save_highscore(high_score_m)
