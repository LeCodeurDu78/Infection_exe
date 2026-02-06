extends Mutation
class_name LightPacketMutation

@export var dash_min := 700.0
@export var dash_max := 2000.0
@export var charge_time := 1.0
@export var cooldown: float = 5.0
@export var duration: float = 0.3


var timer := 0.0
var charge := 0.0
var is_dashing := false
var on_cooldown := false
var direction := Vector2.ZERO

func apply(_virus):
	if on_cooldown or is_dashing:
		return

func hold(delta):
	if not on_cooldown:
		charge += delta
		charge = min(charge, charge_time)
	
func release(virus):
	if not on_cooldown:
		var dir = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		)

		if dir == Vector2.ZERO:
			return

		dir = dir.normalized()

		var power = dash_min + (dash_max - dash_min) * (charge / charge_time)

		is_dashing = true
		timer = duration
		virus.dash(power, dir)
		on_cooldown = true
	charge = 0.0

func get_cooldown() -> float:
	if on_cooldown:
		return timer
	return 0.0

func get_max_cooldown() -> float:
	return cooldown

func process(virus, delta):
	if is_dashing:
		timer -= delta
		if timer <= 0:
			is_dashing = false
			virus.is_dashing = false

	if on_cooldown and not is_dashing:
		timer += delta
		if timer >= cooldown:
			on_cooldown = false
			timer = 0.0
