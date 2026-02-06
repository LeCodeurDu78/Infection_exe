extends Mutation

@export var discretion_multiplier := 0.8

func ready(virus):
	virus.discretion *= discretion_multiplier

func remove(virus):
	virus.discretion /= discretion_multiplier