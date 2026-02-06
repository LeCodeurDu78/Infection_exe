extends CharacterBody2D 

@export var speed := 400.0
@export var infection_rate := 1.0
@export var discretion := 1.0
var invisible := false

var is_dashing := false
var power := 0.0
var direction := Vector2.ZERO

func _physics_process(_delta):
	if is_dashing:
		velocity = direction.normalized() * power
		move_and_slide()
		return 

	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if dir != Vector2.ZERO:
		dir = dir.normalized()

	velocity = dir * speed
	move_and_slide()

func set_invisible(value: bool):
	invisible = value
	modulate.a = 0.4 if value else 1.0

func dash(_power: float, _direction: Vector2):
	is_dashing = true
	power = _power
	direction = _direction