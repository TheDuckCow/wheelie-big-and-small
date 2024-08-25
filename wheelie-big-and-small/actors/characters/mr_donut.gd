extends Node3D

const SPEEDUP := 40.0

@onready var player:AnimationPlayer = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var res = player.animation_finished.connect(keep_playing)
	assert(res == OK)


func keep_playing(anim: String) -> void:
	player.play("ArmatureAction")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerCar:
		print("Sped up by Mr. Donut")
		if abs(body.velocity.z) < SPEEDUP:
			body.velocity.z = -SPEEDUP
		queue_free()
