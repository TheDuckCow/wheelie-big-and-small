extends Camera3D

@export var player: Node3D
@export var min_fov: float = 75.0
@export var max_fov: float = 120.0
@export var max_speed: float = 40.0

func _process(_delta):
	if player:
		# Get the player's velocity 
		var velocity = player.get("velocity")
		
		# Calculate the speed (magnitude of velocity)
		var speed = velocity.length()
		
		# Map the speed to the FOV range
		var target_fov = lerp(min_fov, max_fov, speed / max_speed)
		
		print(target_fov)
		# Set the camera's FOV
		self.fov = target_fov
