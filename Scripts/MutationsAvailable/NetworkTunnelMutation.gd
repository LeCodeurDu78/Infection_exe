extends Mutation
class_name NetworkTunnelMutation

@export var infection_zone_multiplier := 1.2

func ready(virus):
	virus.infection_zone.scale *= infection_zone_multiplier 

func remove(virus):
	virus.infection_zone.scale /= infection_zone_multiplier 
