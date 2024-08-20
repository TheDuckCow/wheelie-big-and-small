extends Control

@export_node_path() var target: NodePath

@onready var _target = get_node(target)
@onready var speedo_label := %speedo
@onready var timer_label := %timer
@onready var debug_label := %debug

var debug := true

func _ready() -> void:
	if not is_instance_valid(_target):
		push_error("No target found for %s" % target)
	var res = Signals.run_ended.connect(_on_run_ended)
	assert(res == OK)
	if debug:
		debug_label.show()
	else:
		debug_label.hide()
	


func _process(_delta: float) -> void:
	if not is_instance_valid(_target):
		return
	var display_speed = abs(round(_target.get_speed()))
	speedo_label.text = "Speed: %s" % display_speed
	
	var elapsed:float = get_parent().run_time_msec()
	timer_label.text = Data.format_time_msec(elapsed)
	var car_count = get_tree().get_nodes_in_group("npc_cars")
	print("Cars? ", len(car_count))
	debug_label.text = "Car count: %s" % len(car_count)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Signals.run_ended.emit(self)
		return


func _on_run_ended(_obstacle: Node) -> void:
	self.hide()
	
