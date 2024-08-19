extends "res://addons/road-generator/nodes/road_manager.gd"

const BEHIND_BUFFER := 150.0
const FOREWARD_BUFFER := -100.0


const RoadScenes = [
	"res://scenes/road_segments/road_piece_a.tscn",
	#"res://scenes/road_segments/road_piece_bump.tscn",
	"res://scenes/road_segments/road_piece_doors.tscn",
	"res://scenes/road_segments/road_piece_overpass.tscn",
	"res://scenes/road_segments/road_piece_random_speed_bump.tscn",
]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_containers()


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
		print("Delete: ", back_container, " at ", back_container.global_transform.origin, " with z", back_z, " vs ", zpos + BEHIND_BUFFER)
		back_container.queue_free()
	if is_instance_valid(front_container) and front_z > zpos + FOREWARD_BUFFER:
		print("Front most: ", front_container, " add cont here ", front_z, " with rp ", front_rp)
		add_new_container(front_container, front_rp)


func add_new_container(sibling: RoadContainer, target_add_rp: RoadPoint) -> void:
	#sibling.validate_edges()
	randomize()
	var load_path:String = RoadScenes.pick_random()
	var scn: PackedScene = load(load_path)
	var new_container:RoadContainer = scn.instantiate()
	self.add_child(new_container)
	
	# pick random edge RP
	new_container.update_edges()
	var first_node: RoadPoint
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
