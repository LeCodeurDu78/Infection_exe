extends Control

## Debug Console
## Execute debug commands with F1
## Type 'help' for available commands

# ========================
# NODES
# ========================
@onready var output_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/OutputScroll/Output
@onready var input_field: LineEdit = $Panel/MarginContainer/VBoxContainer/InputContainer/Input
@onready var panel: Panel = $Panel

# ========================
# STATE
# ========================
var command_history: Array[String] = []
var history_index := -1
var is_console_open := false

# ========================
# COMMANDS
# ========================
var commands := {
	"help": {
		"description": "Show all available commands",
		"usage": "help [command]",
		"function": _cmd_help
	},
	"clear": {
		"description": "Clear console output",
		"usage": "clear",
		"function": _cmd_clear
	},
	"god": {
		"description": "Toggle god mode (invincibility)",
		"usage": "god",
		"function": _cmd_god
	},
	"speed": {
		"description": "Set virus speed",
		"usage": "speed <value>",
		"function": _cmd_speed
	},
	"level": {
		"description": "Set virus level",
		"usage": "level <value>",
		"function": _cmd_level
	},
	"xp": {
		"description": "Add XP to virus",
		"usage": "xp <amount>",
		"function": _cmd_xp
	},
	"spawn_av": {
		"description": "Spawn antivirus",
		"usage": "spawn_av [count]",
		"function": _cmd_spawn_antivirus
	},
	"kill_av": {
		"description": "Destroy all antivirus",
		"usage": "kill_av",
		"function": _cmd_kill_antivirus
	},
	"unlock_all": {
		"description": "Unlock all mutations",
		"usage": "unlock_all",
		"function": _cmd_unlock_all
	},
	"infect_all": {
		"description": "Instantly infect all targets",
		"usage": "infect_all",
		"function": _cmd_infect_all
	},
	"particle": {
		"description": "Spawn particle effect",
		"usage": "particle <type>",
		"function": _cmd_particle
	},
	"notify": {
		"description": "Test notification system",
		"usage": "notify <type> <message>",
		"function": _cmd_notify
	},
	"fps": {
		"description": "Show FPS counter",
		"usage": "fps",
		"function": _cmd_fps
	},
	"time_scale": {
		"description": "Set game time scale",
		"usage": "time_scale <value>",
		"function": _cmd_time_scale
	},
	"reset": {
		"description": "Reset game state",
		"usage": "reset",
		"function": _cmd_reset
	},
}

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	visible = false
	is_console_open = false
	
	# Connect signals
	input_field.text_submitted.connect(_on_command_submitted)
	
	_log("[color=#39FF14]Debug Console Ready[/color]", false)
	_log("Type 'help' for available commands", false)

func _input(event: InputEvent) -> void:
	# Toggle console with F1
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		toggle_console()
		get_viewport().set_input_as_handled()
	
	# Navigate history with Up/Down
	if is_console_open and event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			_navigate_history(-1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN:
			_navigate_history(1)
			get_viewport().set_input_as_handled()

# ========================
# CONSOLE CONTROL
# ========================
func toggle_console() -> void:
	"""Toggle console visibility"""
	is_console_open = not is_console_open
	visible = is_console_open
	
	if is_console_open:
		input_field.grab_focus()
		get_tree().paused = true  # Don't pause game with console
	else:
		input_field.release_focus()
		get_tree().paused = false

# ========================
# COMMAND HANDLING
# ========================
func _on_command_submitted(command_text: String) -> void:
	"""Execute a command"""
	command_text = command_text.strip_edges()
	
	if command_text.is_empty():
		return
	
	# Add to history
	command_history.append(command_text)
	history_index = command_history.size()
	
	# _log command
	_log("[color=yellow]> " + command_text + "[/color]", false)
	
	# Parse command
	var parts := command_text.split(" ", false)
	var cmd := parts[0].to_lower()
	var args := parts.slice(1)
	
	# Execute
	if cmd in commands:
		get_tree().paused = false  # Ensure game is not paused when executing commands
		commands[cmd].function.call(args)
		get_tree().paused = true  # Pause again after command execution
	else:
		_log("[color=red]Unknown command: " + cmd + "[/color]")
		_log("Type 'help' for available commands")
	
	# Clear input
	input_field.clear()

func _navigate_history(direction: int) -> void:
	"""Navigate command history with arrow keys"""
	if command_history.is_empty():
		return
	
	history_index = clamp(history_index + direction, 0, command_history.size())
	
	if history_index < command_history.size():
		input_field.text = command_history[history_index]
		input_field.caret_column = input_field.text.length()
	else:
		input_field.clear()

# ========================
# OUTPUT
# ========================
func _log(message: String, add_timestamp: bool = true) -> void:
	"""Add a message to console output"""
	var text := ""
	
	if add_timestamp:
		var time := Time.get_ticks_msec() / 1000.0
		text = "[color=gray][%.2fs][/color] " % time
	
	text += message + "\n"
	output_label.append_text(text)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	if is_instance_valid(output_label):
		output_label.scroll_to_line(output_label.get_line_count() - 1)

# ========================
# COMMANDS IMPLEMENTATION
# ========================

func _cmd_help(args: Array) -> void:
	"""Show help for all commands or specific command"""
	if args.size() > 0:
		var cmd = args[0].to_lower()
		if cmd in commands:
			_log("[color=#39FF14]" + cmd + "[/color]")
			_log("  " + commands[cmd].description)
			_log("  Usage: " + commands[cmd].usage)
		else:
			_log("[color=red]Unknown command: " + cmd + "[/color]")
	else:
		_log("[color=#39FF14]Available Commands:[/color]")
		for cmd in commands:
			_log("  [color=cyan]%s[/color] - %s" % [cmd, commands[cmd].description])

func _cmd_clear(_args: Array) -> void:
	"""Clear console output"""
	output_label.clear()
	_log("[color=#39FF14]Console cleared[/color]", false)

func _cmd_god(_args: Array) -> void:
	"""Toggle god mode"""
	if not GameManager.virus_node:
		_log("[color=red]No virus found[/color]")
		return
	
	# Toggle invulnerability
	var god_mode = not GameManager.virus_node.get("invulnerable")
	GameManager.virus_node.set("invulnerable", god_mode)
	
	_log("[color=#39FF14]God mode: " + ("ON" if god_mode else "OFF") + "[/color]")

func _cmd_speed(args: Array) -> void:
	"""Set virus speed"""
	if args.size() == 0:
		_log("[color=red]Usage: speed <value>[/color]")
		return
	
	if not GameManager.virus_node:
		_log("[color=red]No virus found[/color]")
		return
	
	var speed := float(args[0])
	GameManager.virus_node.base_speed = speed
	_log("[color=#39FF14]Speed set to: " + str(speed) + "[/color]")

func _cmd_level(args: Array) -> void:
	"""Set virus level"""
	if args.size() == 0:
		_log("[color=red]Usage: level <value>[/color]")
		return
	
	if not GameManager.virus_node:
		_log("[color=red]No virus found[/color]")
		return
	
	var level := int(args[0])
	GameManager.virus_node.current_level = clamp(level, 1, GameManager.virus_node.MAX_LEVEL)
	_log("[color=#39FF14]Level set to: " + str(GameManager.virus_node.current_level) + "[/color]")

func _cmd_xp(args: Array) -> void:
	"""Add XP to virus"""
	if args.size() == 0:
		_log("[color=red]Usage: xp <amount>[/color]")
		return
	
	if not GameManager.virus_node:
		_log("[color=red]No virus found[/color]")
		return
	
	var amount := int(args[0])
	GameManager.virus_node.add_xp(Vector2.ZERO, amount)
	_log("[color=#39FF14]Added " + str(amount) + " XP[/color]")

func _cmd_spawn_antivirus(args: Array) -> void:
	"""Spawn antivirus"""
	var count := 1 if args.size() == 0 else int(args[0])
	
	# This would need access to AntivirusManager
	EventBus.spawn_antivirus.emit(count)
	# For now, emit event
	EventBus.emit_notification("Spawning " + str(count) + " antivirus", "info")
	_log("[color=#39FF14]Spawn request sent: " + str(count) + " antivirus[/color]")

func _cmd_kill_antivirus(_args: Array) -> void:
	"""Kill all antivirus"""
	var antiviruses := get_tree().get_nodes_in_group("antivirus")
	var count := antiviruses.size()
	
	for av in antiviruses:
		if is_instance_valid(av):
			av.queue_free()
	
	_log("[color=#39FF14]Destroyed " + str(count) + " antivirus[/color]")

func _cmd_unlock_all(_args: Array) -> void:
	"""Unlock all mutations"""
	if not GameManager.virus_node:
		_log("[color=red]No virus found[/color]")
		return
	
	if not GameManager.virus_node.has_node("MutationManager"):
		_log("[color=red]MutationManager not found[/color]")
		return
	
	EventBus.unlock_all_mutations.emit()
	_log("[color=#39FF14]All mutations unlocked[/color]")
	EventBus.emit_notification("All mutations unlocked!", "success")

func _cmd_infect_all(_args: Array) -> void:
	"""Instantly infect all targets"""
	var infectables := get_tree().get_nodes_in_group("infectables")
	var count := infectables.size()
	
	for target in infectables:
		if is_instance_valid(target) and target.has_method("instant_infect"):
			target.instant_infect()
	
	_log("[color=#39FF14]Infected " + str(count) + " targets[/color]")

func _cmd_particle(args: Array) -> void:
	"""Spawn particle effect at virus position"""
	if args.size() == 0:
		_log("[color=red]Usage: particle <type>[/color]")
		_log("Types: infection, level_up, virus_hit, mutation_activated, scan_wave")
		return
	
	if not GameManager.virus_node:
		_log("[color=red]No virus found[/color]")
		return
	
	var type = args[0]
	var pos := GameManager.virus_node.global_position
	ParticleManager.spawn_particle(type, pos)
	_log("[color=#39FF14]Spawned particle: " + type + "[/color]")

func _cmd_notify(args: Array) -> void:
	"""Test notification system"""
	if args.size() < 2:
		_log("[color=red]Usage: notify <type> <message>[/color]")
		_log("Types: info, success, warning, error")
		return
	
	var type = args[0]
	var message = " ".join(args.slice(1))
	EventBus.emit_notification(message, type)
	_log("[color=#39FF14]Notification sent[/color]")

func _cmd_fps(_args: Array) -> void:
	"""Show FPS"""
	var fps := Engine.get_frames_per_second()
	_log("[color=#39FF14]FPS: " + str(fps) + "[/color]")

func _cmd_time_scale(args: Array) -> void:
	"""Set game time scale"""
	if args.size() == 0:
		_log("[color=#39FF14]Current time scale: " + str(Engine.time_scale) + "[/color]")
		return
	
	var _scale := float(args[0])
	Engine.time_scale = clamp(_scale, 0.1, 5.0)
	_log("[color=#39FF14]Time scale set to: " + str(Engine.time_scale) + "[/color]")

func _cmd_reset(_args: Array) -> void:
	"""Reset game state"""
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
	_log("[color=#39FF14]Game reset[/color]")
