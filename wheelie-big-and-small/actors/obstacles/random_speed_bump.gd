extends Node3D

# Called when the node enters the scene tree for the first time.
# From the 4 speed bump children, select 1 random and queue free the others.
func _ready():
	# Get the children of this node
	var children = get_children()
	
	# Ensure we have exactly 4 children
	if children.size() == 4:
		# Randomly select one child to keep
		var selected_index = randi() % 4
		
		# Queue free the rest of the children
		for i in range(4):
			if i != selected_index:
				children[i].queue_free()
