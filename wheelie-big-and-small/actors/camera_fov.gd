extends Camera3D

@export var player: Node3D
@export var min_fov: float = 70.0
@export var max_fov: float = 90.0
@export var max_speed: float = 120.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player:
		# Get the player's velocity assuming it has a RigidBody3D or CharacterBody3D
		var velocity = player.get("velocity")
		
		# Calculate the speed (magnitude of velocity)
		var speed = velocity.length()
		
		# Map the speed to the FOV range
		var target_fov = lerp(min_fov, max_fov, speed / max_speed)
		
		print(target_fov)
		# Set the camera's FOV
		self.fov = target_fov
