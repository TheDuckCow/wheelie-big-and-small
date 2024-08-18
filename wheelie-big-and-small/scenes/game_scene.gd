extends Node3D

@onready var road_manager: RoadManager= get_node("RoadManager")

var ran_once = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("GameScene starting ready")
	# For some reason, doing it here in ready wasn't enough, hmm
	# not that it should have been necessary at all anyways
	#road_manager.call_deferred("rebuild_all_containers")
	#road_manager.rebuild_all_containers()
	Signals.run_ended.connect(_run_ended)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process_physics(_delta: float) -> void:
	if not ran_once:
		ran_once = true
		print("Game scene running: rebuild all containers")
		road_manager.rebuild_all_containers()
		print("Game scene ran: rebuild all containers")


func _run_ended(source_node: Node) -> void:
	print("The run was ended by: ", source_node)
