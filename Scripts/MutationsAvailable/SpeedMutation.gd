extends Mutation

@export var speed_multiplier := 1.2

func ready(virus):
	virus.speed *= speed_multiplier

func remove(virus):
	virus.speed /= speed_multiplier