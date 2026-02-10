extends Mutation
class_name FinalMutagenesisMutation

@export var multiplier := 1.2

func ready(virus):
	virus.max_health *= multiplier
	virus.base_speed *= multiplier
	virus.infection_rate *= multiplier
	virus.discretion *= multiplier

	EventBus.virus_max_health.emit(virus.max_health)

func remove(virus):
	virus.max_health /= multiplier
	virus.base_speed /= multiplier
	virus.infection_rate /= multiplier
	virus.discretion /= multiplier

	EventBus.virus_max_health.emit(virus.max_health)