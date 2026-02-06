extends Node

var total_infectables := 0
var infected_count := 0

func register_infectable():
	total_infectables += 1

func on_infected():
	infected_count += 1

func on_cleaned():
	infected_count = max(0, infected_count - 1)

func get_infection_percent() -> float:
	if total_infectables == 0:
		return 0.0
	return float(infected_count) / float(total_infectables) * 100.0
