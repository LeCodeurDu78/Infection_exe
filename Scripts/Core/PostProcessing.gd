extends CanvasLayer

@onready var glitch_shader = $ColorRect.material

func _ready():
	EventBus.virus_damaged.connect(_trigger_glitch)
	EventBus.threat_level_changed.connect(_update_glitch_intensity)

func _trigger_glitch(_amount: int, _remaining: int):
	# Temporarily increase glitch
	var last_shake_rate = glitch_shader.get_shader_parameter("shake_rate")
	glitch_shader.set_shader_parameter("shake_rate", 0.5)
	await get_tree().create_timer(0.2).timeout
	glitch_shader.set_shader_parameter("shake_rate", last_shake_rate)

func _update_glitch_intensity(_old: int, _new: int):
	match _new:
		GameManager.ThreatLevel.LOW:
			glitch_shader.set_shader_parameter("shake_rate", 0.0)
		GameManager.ThreatLevel.MEDIUM:
			glitch_shader.set_shader_parameter("shake_rate", 0.1)
		GameManager.ThreatLevel.CRITICAL:
			glitch_shader.set_shader_parameter("shake_rate", 0.2)