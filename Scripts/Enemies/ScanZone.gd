extends Area2D

@export var warning_time := 2
@export var scan_time := 1.5

var state := "warning"
var timer := 0.0

var virus_inside := false
var cleaning_targets: Array[Infectable] = []

func _ready():
	modulate = Color(1, 0.5, 0.2, 0.4)

	match GameManager.get_threat_level():
		GameManager.ThreatLevel.LOW:
			scale = Vector2(3, 3)

		GameManager.ThreatLevel.MEDIUM:
			scale = Vector2(4, 4)

		GameManager.ThreatLevel.CRITICAL:
			scale = Vector2(5, 5)

func _process(delta):
	timer += delta

	match state:
		"warning":
			if timer >= warning_time:
				_start_scan()

		"scan":
			_clean()
			if timer >= scan_time:
				queue_free()

func _start_scan():
	state = "scan"
	timer = 0.0
	modulate = Color(1, 0, 0, 0.6)

func _clean():
	if virus_inside:
		get_tree().reload_current_scene()
	if cleaning_targets.size() > 0:
		for target in cleaning_targets:
			target.clean()
	
	cleaning_targets.clear()

func _on_body_entered(body):
	if body.name == "Virus":
		virus_inside = true

func _on_area_entered(area):
	if area is Infectable and area.infected:
		cleaning_targets.append(area)

func _on_body_exited(body):
	if body.name == "Virus":
		virus_inside = false
