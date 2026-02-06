extends Mutation

@export var duration := 5.0
@export var cooldown := 20.0

var duration_timer := 0.0
var cooldown_timer := 0.0

var active := false
var on_cooldown := false

func apply(virus):
	if on_cooldown or active:
		return

	active = true
	duration_timer = duration
	virus.set_invisible(true)

func get_cooldown() -> float:
	if on_cooldown:
		return cooldown_timer
	return 0.0

func get_max_cooldown() -> float:
	return cooldown

func _end_invisibility(virus):
	active = false
	on_cooldown = true
	cooldown_timer = cooldown
	virus.set_invisible(false)

func process(virus, delta):
	if active:
		duration_timer -= delta
		if duration_timer <= 0:
			_end_invisibility(virus)

	elif on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			on_cooldown = false