extends Mutation
class_name RapidInfectionMutation

@export var infection_rate_multiplier := 1.2

func ready(virus):
	virus.infection_rate *= infection_rate_multiplier

func remove(virus):
	virus.infection_rate /= infection_rate_multiplier