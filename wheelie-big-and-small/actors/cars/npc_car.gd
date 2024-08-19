extends CharacterBody3D

@onready var speed := randf_range(5, 15)
@export var base_mesh_path: NodePath


func _ready() -> void:
	if base_mesh_path:
		randomize_car_mat()


func randomize_car_mat():
	var car_mesh:MeshInstance3D = get_node_or_null(base_mesh_path)
	if not is_instance_valid(car_mesh):
		push_warning("Car mesh was invalid for %s" % self)
		return
	
	var mat:Material = car_mesh.get_surface_override_material(0)
	var mat_mod:Material = mat.duplicate(true)
	var randcol:Color = mat_mod.get_shader_parameter("col")
	randcol.h = fmod(randcol.h + randf(), 1.0) 
	mat_mod.set_shader_parameter("col", randcol)
	var randstar:Color = mat_mod.get_shader_parameter("col_star")
	randstar.h = fmod(randstar.h + randf(), 1.0) 
	mat_mod.set_shader_parameter("col_star", randstar)
	car_mesh.set_surface_override_material(0, mat_mod)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity = Vector3(0, 0, -speed)
	move_and_slide()
