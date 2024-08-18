extends Control

@export_node_path() var target: NodePath

@onready var _target = get_node(target)
@onready var speedo_label := %speedo
@onready var timer_label := %timer

func _ready() -> void:
	if not is_instance_valid(_target):
		push_error("No target found for %s" % target)

func _process(_delta: float) -> void:
	if not is_instance_valid(_target):
		return
	var display_speed = abs(round(_target.get_speed()))
	speedo_label.text = "Speed: %s" % display_speed
	
	var elapsed:float = get_parent().run_time_msec()
	timer_label.text = Data.format_time_msec(elapsed)
