extends Node

var trauma := 0.0
var trauma_power := 2.0
var decay := 1.5

var max_offset := Vector2(50, 50)
var max_rotation := 10.0

var camera: Camera2D
var original_position := Vector2.ZERO

func _ready():
	EventBus.screen_shake_requested.connect(_on_shake_requested)
	EventBus.virus_spawned.connect(_on_virus_spawned)
	if camera:
		original_position = camera.offset
		print(camera.get_parent().name)

func _process(delta):
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0.0)
		_apply_shake()

func _on_virus_spawned(virus: Node2D):
	camera = virus.get_node("Camera2D")
	if camera:
		original_position = camera.offset

func _on_shake_requested(intensity: float, _duration: float):
	add_trauma(intensity)

func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)

func _apply_shake():
	if not camera:
		return
	
	var shake = pow(trauma, trauma_power)
	camera.offset.x = original_position.x + max_offset.x * shake * randf_range(-1, 1)
	camera.offset.y = original_position.y + max_offset.y * shake * randf_range(-1, 1)
	camera.rotation_degrees = max_rotation * shake * randf_range(-1, 1)
