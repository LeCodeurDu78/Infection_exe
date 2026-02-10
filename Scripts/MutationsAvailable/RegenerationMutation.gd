extends Mutation
class_name RegenerationMutation

@export var regen_per_second := 2.0

func process(virus: Node2D, delta: float) -> void:
	var heal_amount = regen_per_second * delta
	if heal_amount > 0 and virus.current_health < virus.max_health:
		virus.current_health = min(virus.current_health + heal_amount, virus.max_health)
		EventBus.virus_healed.emit(heal_amount, virus.current_health)
