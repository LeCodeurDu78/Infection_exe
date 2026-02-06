extends Node
class_name AntivirusManager

@export var antivirus_scene: PackedScene
@export var spawn_points: Array[Node2D] = []

@export var base_count := 2
@export var max_count := 5

var antivirus_list: Array = []

func _process(_delta):
	update_antivirus_count()

func get_target_count() -> int:
	match GameManager.get_threat_level():
		GameManager.ThreatLevel.LOW:
			return base_count
		GameManager.ThreatLevel.MEDIUM:
			return base_count + 1
		GameManager.ThreatLevel.CRITICAL:
			return max_count
	return base_count

func update_antivirus_count():
	var target = get_target_count()

	while antivirus_list.size() < target:
		spawn_antivirus()

	while antivirus_list.size() > target:
		remove_antivirus()

func spawn_antivirus():
	if not antivirus_scene or spawn_points.is_empty():
		return

	var av = antivirus_scene.instantiate()
	var point = spawn_points.pick_random()
	av.global_position = point.global_position

	get_parent().add_child(av)
	antivirus_list.append(av)

func remove_antivirus():
	var av = antivirus_list.pop_back()
	if is_instance_valid(av):
		av.queue_free()
