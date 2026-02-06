extends Mutation
class_name RebootMutation


@export var cooldown: String = "one-shot"
@export var duration: float = 0.0

func apply(virus):
	# Implement one-shot revive
	pass

func remove(virus):
	pass
