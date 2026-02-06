extends Control

var mutation_manager : MutationManager

func setup(manager: MutationManager):
	mutation_manager = manager
	visible = true
	get_tree().paused = true

	$MutationButton1.text = mutation_manager.to_show[0].name
	$MutationButton2.text = mutation_manager.to_show[1].name
	#$MutationButton3.text = mutatidon_manager.to_show[2].name

func _on_mutation_selected(mutation: Mutation):
	mutation_manager.activate_mutation(mutation)
	get_tree().paused = false
	visible = false

func _mutation1_pressed():
	_on_mutation_selected(mutation_manager.to_show[0])

func _mutation2_pressed():
	_on_mutation_selected(mutation_manager.to_show[1])

func _mutation3_pressed():
	_on_mutation_selected(mutation_manager.to_show[2])
