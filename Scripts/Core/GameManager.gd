extends Node

var total_infectables := 0
var infected_count := 0

var points := 0
var actual_level := 1
var all_levels: Array[int] = [20, 40, 60, 80, 100]
@onready var mutation_manager := get_tree().root.get_node("Main/VirusSpawner/Virus/MutationManager") as MutationManager

enum ThreatLevel { LOW, MEDIUM, CRITICAL }

func register_infectable():
	total_infectables += 1
	infected_count += 1

func on_infected(points_worth: int):
	infected_count -= 1
	points += points_worth
	
	if points >= all_levels[actual_level - 1]:
		points -= all_levels[actual_level - 1]
		actual_level += 1
		mutation_manager.unlock_mutations()
		
func get_virus_xp() -> String:
	return str(points) + " / " + str(all_levels[actual_level - 1])

func get_infection_percent() -> float:
	if total_infectables == 0:
		return 0
	return (1 - (float(infected_count) / float(total_infectables))) * 100

func get_threat_level() -> ThreatLevel:
	var percent = get_infection_percent()
	if percent < 30: return ThreatLevel.LOW
	elif percent < 70: return ThreatLevel.MEDIUM
	else: return ThreatLevel.CRITICAL