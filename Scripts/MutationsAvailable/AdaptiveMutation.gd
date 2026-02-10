extends Mutation
class_name AdaptiveMutation

@export var multiplier := 1.05
var virus_ref = null

func ready(virus):
	EventBus.virus_leveled_up.connect(_on_virus_leveled_up)
	virus_ref = virus

func _on_virus_leveled_up(_new_level):
	# Randomly choose a stat to boost
	var stat_to_boost = randi() % 4  
	match stat_to_boost:
		0:
			virus_ref.max_health *= multiplier
			EventBus.virus_max_health.emit(virus_ref.max_health)
		1:
			virus_ref.base_speed *= multiplier
		2:
			virus_ref.infection_rate *= multiplier
		3:
			virus_ref.discretion *= multiplier