extends Node
class_name MutationManager

@export var available_mutations : Array[Mutation] = []
var active_mutations : Array[Mutation] = []
var active_keys : Dictionary[Mutation, String] = {}
var to_show: Array[Mutation] = []

@onready var ui = get_tree().root.get_node("Main/UI/MutationUI")

func _process(delta: float):
	for mutation in active_mutations:
		if mutation.has_method("process"):
			mutation.process(get_parent(), delta)

		if mutation.has_method("apply"):
			if Input.is_action_just_pressed(active_keys[mutation]):
				mutation.apply(get_parent())

		if mutation.has_method("hold"):
			if Input.is_action_pressed(active_keys[mutation]):
				mutation.hold(delta)

		if mutation.has_method("release"):
			if Input.is_action_just_released(active_keys[mutation]):
				mutation.release(get_parent())

func get_all_cooldowns() -> Dictionary[String, float]:
	var cooldowns: Dictionary[String, float] = {}
	for mutation in active_mutations:
		if mutation.has_method("get_cooldown"):
			cooldowns[active_keys[mutation]] = mutation.get_cooldown()
	return cooldowns

func get_all_max_cooldowns() -> Dictionary[String, float]:
	var cooldowns: Dictionary[String, float] = {}
	for mutation in active_mutations:
		if mutation.has_method("get_max_cooldown"):
			cooldowns[active_keys[mutation]] = mutation.get_max_cooldown()
	return cooldowns

func unlock_mutations():
	for mutation in available_mutations:
		if mutation in active_mutations:
			continue

		# On compare maintenant avec GameManager.points
		var level = GameManager.actual_level
		print(level)
		if level >= mutation.level_min and level <= mutation.level_max:
			if mutation not in to_show:
				to_show.append(mutation)
	
	if to_show.size() >= 2: # On attend d'en avoir au moins 2 pour proposer un choix
		to_show.shuffle()
		show_mutation_ui()

func show_mutation_ui():
	ui.setup(self)

func activate_mutation(mutation: Mutation):
	active_mutations.append(mutation)
	mutation.ready(get_parent())

	if mutation.has_method("apply") and active_keys.size() <= 5:
		active_keys[mutation] = "mutation" + str(active_keys.size() + 1)

	available_mutations.erase(mutation)
	to_show =  []