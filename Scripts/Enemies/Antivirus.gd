extends CharacterBody2D

# ========================
# CONFIG
# ========================
@export var speed := 200.0

@export var scan_scene: PackedScene
@export var scan_cooldown := 4.0
@export var detectionVector := Vector2(12, 12)

# ========================
# STATE
# ========================
var state := "wander" # wander | chase | move_to_clean | clean
var target: Node2D = null

var wander_direction := Vector2.ZERO
var wander_timer := 0.0

var scan_timer := 0.0

# ========================
# MANAGERS
# ========================
@onready var virus : Node2D = get_tree().root.get_node("Main/VirusSpawner/Virus") as Node2D

# ========================
# LIFECYCLE
# ========================
func _ready():
	randomize()
	_pick_new_direction()

# ========================
# MAIN LOOP
# ========================
func _physics_process(delta):
	$DetectionArea.scale = detectionVector * virus.discretion 
	scan_timer += delta

	if scan_timer >= scan_cooldown:
		launch_scan()
		scan_timer = 0.0

	if state == "wander":
		_wander(delta)
	elif state == "chase":
		_chase()

	move_and_slide()

# ========================
# STATES
# ========================
func _wander(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		_pick_new_direction()

	velocity = wander_direction * speed * get_speed_multiplier()

func _pick_new_direction():
	wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_timer = randf_range(1.0, 3.0)

func _chase():
	if not is_instance_valid(target) or target.invisible:
		target = null
		state = "wander"
		return

	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed * get_speed_multiplier()

# ========================
# SCAN
# ========================
func launch_scan():
	if not scan_scene:
		return

	var scan = scan_scene.instantiate()

	if target:
		scan.global_position = target.global_position
	else:
		return

	get_parent().add_child(scan)

# ========================
# DETECTION
# ========================
func _on_detection_entered(body):
	if body.name == "InfectionZone" and not body.get_parent().invisible:
			target = body.get_parent() as Node2D
			state = "chase"

func _on_detection_exited(body):
	if body.get_parent() == target:
		target = null
		state = "wander"

func _on_body_entered(body):
	if body.name == "Virus":
		print("Virus éliminé")
		body.queue_free()

# ========================
# DIFFICULTY
# ========================
func get_speed_multiplier() -> float:
	match GameManager.get_threat_level():
		GameManager.ThreatLevel.LOW:
			return 1.0
		GameManager.ThreatLevel.MEDIUM:
			return 1.3
		GameManager.ThreatLevel.CRITICAL:
			return 1.7
	return 1.0
