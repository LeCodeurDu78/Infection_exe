extends Mutation
class_name DataCorruptionMutation

@export var xp_multiplier := 1.15
var base_xp_multplier := 1.0

func ready(_virus):
	base_xp_multplier = _virus.xp_multiplier
	_virus.xp_multiplier = xp_multiplier

func remove(_virus):
	_virus.xp_multiplier = base_xp_multplier