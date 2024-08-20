extends "res://addons/road-generator/nodes/road_manager.gd"

const MAX_CAR_COUNT := 12
const BEHIND_BUFFER := 200.0
const FOREWARD_BUFFER := -100.0


const RoadScenes = [
	"res://scenes/road_segments/road_piece_a.tscn",
	#"res://scenes/road_segments/road_piece_bump.tscn",
	"res://scenes/road_segments/road_piece_doors.tscn",
	"res://scenes/road_segments/road_piece_overpass.tscn",
	"res://scenes/road_segments/road_piece_random_speed_bump.tscn",
]

var Cars = [
	load("res://actors/cars/car01.tscn"),
	load("res://actors/cars/car02.tscn"),
	load("res://actors/cars/car03.tscn"),
	load("res://actors/cars/car04.tscn"),
	load("res://actors/cars/car05.tscn"),
]

@onready var placer_parent = get_node("../enviros")

const tree_placer := preload("res://models/wheelie_collections/floor_multi_instance.tscn")
var Trees := [
		load("res://models/wheelie_bits/tree_pine_bendy.tres"),
		load("res://models/wheelie_bits/tree_pine_jagged.tres"),
	]
	

var checkpoint_distance: float = 100.0 # Distance for checkpoints
var next_checkpoint_position: float = checkpoint_distance
var ended := false # Track whether the game has ended

const checkpoint_scene := preload("res://actors/obstacles/checkpoint.tscn")
var active_checkpoint: Node3D = null

# other wheelie bits
func _ready():
	Data.checkpoint_timer_s = 5.0 # Start with 5 seconds
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update_containers()
	place_enviros()
	
	print("TIME LEFT: ", Data.checkpoint_timer_s)
	# Update the timer
	if not ended:
		Data.checkpoint_timer_s -= delta
		if Data.checkpoint_timer_s <= 0:
			_end_game()
		_check_spawn_checkpoint()

func _check_spawn_checkpoint() -> void:
	var cam = get_viewport().get_camera_3d()
	var zpos = cam.global_transform.origin.z
	print("POSITION: ", zpos)
	if active_checkpoint and zpos <= active_checkpoint.global_transform.origin.z:
		_respawn_checkpoint()

	if zpos <= next_checkpoint_position:
		_spawn_checkpoint()
		next_checkpoint_position -= checkpoint_distance

func _spawn_checkpoint() -> void:
	Data.checkpoint_timer_s += 5.0
	print("Checkpoint reached! Time added: 5 seconds")

	# If there's an active checkpoint, remove it
	if active_checkpoint:
		active_checkpoint.queue_free()

	active_checkpoint = checkpoint_scene.instantiate()
	self.add_child(active_checkpoint)

	var cam = get_viewport().get_camera_3d()
	active_checkpoint.global_transform.origin = Vector3(0, 0, next_checkpoint_position)

func _respawn_checkpoint() -> void:
	if active_checkpoint:
		active_checkpoint.global_transform.origin.z -= 100.0 # Move checkpoint further away

func _end_game() -> void:
	print("==================GAME ENDED Time's up!")
	Signals.emit_signal("run_ended", self)
	ended = true
	
func update_containers() -> void:
	var cam := get_viewport().get_camera_3d()
	var zpos = cam.global_transform.origin.z
	
	#var target_del: RoadContainer
	#var target_del_zmin: float 
	#var target_add: RoadContainer
	#var target_add_zmin: float
	#var target_add_rp: RoadPoint
	
	var front_container: RoadContainer
	var front_rp: RoadPoint
	var front_z:float # ie larger negative
	var back_container: RoadContainer
	var back_z:float # ie smaller negative
	var didset := false
	
	var conts = get_containers()
	for _cont in conts:
		var container:RoadContainer = _cont
		var max_z:float
		var min_z: float
		var min_z_rp: RoadPoint
		
		for _rp in container.get_roadpoints(): # Technically should just do edegs
			if not max_z:
				max_z = _rp.global_transform.origin.z
				min_z = _rp.global_transform.origin.z
				min_z_rp = _rp
				continue
			if _rp.global_transform.origin.z < min_z:
				min_z = _rp.global_transform.origin.z
				min_z_rp = _rp
			if _rp.global_transform.origin.z > max_z:
				max_z = _rp.global_transform.origin.z
		
		# Goal: separately find the containers most behind and most in front
		if not didset or max_z > back_z: #zpos + BEHIND_BUFFER:
			#print("SHOULD QUEUE FREE: ", container, " at ", max_z, "vs cam", zpos )
			#container.queue_free()
			back_z = max_z
			back_container = container
			#if not target_del_zmin or min_z > target_del_zmin:
			#	target_del = container
			#	target_del_zmin = min_z
		if not didset or min_z < front_z: #zpos + BEHIND_BUFFER:
			front_container = container
			front_rp = min_z_rp
			front_z = min_z
			#print("Should add NEW container to:", container, " at minz ", min_z, "vs cam", zpos )
			#if not target_add_zmin or min_z < target_add_zmin:
			#	target_add = container
			#	target_add_zmin = min_z
		didset = true
	
	# Now decide what to do
	if is_instance_valid(back_container) and back_z > zpos + BEHIND_BUFFER:
		# Condition to remove container as it's too positive (forward = neg z dir)
		# e.g. cam at -50 units with the LOWEST z RP at -25 (so everything is *higher*), do cull as buffer is 50
		#print("Delete: ", back_container, " at ", back_container.global_transform.origin, " with z", back_z, " vs ", zpos + BEHIND_BUFFER)
		back_container.queue_free()
	if is_instance_valid(front_container) and front_z > zpos + FOREWARD_BUFFER:
		#print("Front most: ", front_container, " add cont here ", front_z, " with rp ", front_rp)
		add_new_container(front_rp)


func add_new_container(target_add_rp: RoadPoint) -> void:
	print("Add new container for RP ", target_add_rp)
	randomize()
	var load_path:String = RoadScenes.pick_random()
	var scn: PackedScene = load(load_path)
	var new_container:RoadContainer = scn.instantiate()
	self.add_child(new_container)
	
	# pick random edge RP
	new_container.update_edges()
	var maxz: float
	var new_rp: RoadPoint
	for _path in new_container.edge_rp_locals:
		var _rp = new_container.get_node(_path)
		if not maxz:
			maxz = _rp.global_transform.origin.z
			new_rp = _rp
		if _rp.global_transform.origin.z > maxz:
			maxz = _rp.global_transform.origin.z
			new_rp = _rp

	var offset:Vector3 = new_rp.global_transform.origin - target_add_rp.global_transform.origin
	new_container.global_transform.origin -= offset
	print("Now add cars..?")
	var res = new_container.on_road_updated.connect(add_cars_to_lanes)
	assert(res == OK)


#func add_cars_to_lanes(container: RoadContainer) -> void:
func add_cars_to_lanes(segments: Array) -> void:
	if not is_inside_tree():
		return
	print("Segments:", segments)
	for seg in segments:
		var lanes:Array = seg.get_lanes()
		if not lanes:
			push_warning("No lanes found in container seg: %s of %s" % [seg, seg.container.name])
			continue
		lanes.shuffle()
		var num_lanes:int = len(lanes)
		var spawn_count = randi_range(0, num_lanes -1)
		spawn_count = clamp(spawn_count, 0, 4)
		#print("Spawning cars for %s/%s lanes" % [spawn_count, num_lanes])
		for _idx in range(spawn_count):
			var car_count := len(get_tree().get_nodes_in_group("npc_cars"))
			if car_count >= MAX_CAR_COUNT:
				return
			var car_packed:PackedScene = Cars.pick_random()
			var car_child:NpcCar = car_packed.instantiate()
			
			var lane:RoadLane = lanes[_idx] # get teh lane, then curve, the pstion from random index oncurv,e them to global.
			var rand_offset:float = randf() * lane.curve.get_baked_length()
			var placement:Vector3 = lane.curve.sample_baked(rand_offset)
			
			add_child(car_child)
			car_child.global_transform.origin = lane.to_global(placement)
			car_child.global_rotation.y = PI #-PI/2
			#print("Added car %s at %" % [car_child, placement])


func place_enviros() -> void:
	var cam_posz: float = get_viewport().get_camera_3d().global_transform.origin.z
	for ch in placer_parent.get_children():
		if not ch.global_transform.origin.z > cam_posz + 25:
			continue
		ch.global_transform.origin.z -= 150
		
		# now randomize the multi mesh instances
		var use_floor: bool = true # randf() > 0.5
		var left: Node3D
		var right: Node3D
		var mesh: ArrayMesh
		if use_floor:
			left = ch.get_node("floor_L")
			right = ch.get_node("floor_R")
			#var packed_mesh = Trees.pick_random()
			#var inst_mesh = Trees.pick_random() # packed_mesh.instantiate()
			mesh = Trees.pick_random() # inst_mesh # Trees.pick_random()
		else:
			pass
		
		for _node in [left, right]:
			var multi_obj:MultiMeshInstance3D = _node
			multi_obj.multimesh.mesh = mesh
			
