class_name HotkeyRebindButton
extends Control

@onready var label = $Label as Label
@onready var button = $Button as Button

@export var action_name : String = "move_left"

func _ready():
	var key = SaveManager.data.options.keysbiding.get(action_name, 0)
	var input = InputEventKey.new()
	input.physical_keycode = key

	if key != 0:
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, input)

	
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()

func set_action_name() -> void:
	label.text = action_name.replace("_", " ").capitalize()

func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	if action_events.size() > 0:
		var action_event = action_events[0]
		var keycode = DisplayServer.keyboard_get_keycode_from_physical(action_event.physical_keycode)
		var action_keycode = OS.get_keycode_string(keycode)

		match action_keycode:
			"Ampersand":
				action_keycode = "1"
			"é":
				action_keycode = "2"
			"QuoteDbl":
				action_keycode = "3"
			"Apostrophe":
				action_keycode = "4"
			"ParenLeft":
				action_keycode = "5"
			"Minus":
				action_keycode = "6"
			"È":
				action_keycode = "7"
			"Underscore":
				action_keycode = "8"
			"Ç":
				action_keycode = "9"
			"Equal":
				action_keycode = "0"
			
		button.text = "%s" % action_keycode
	else:
		button.text = "No key assigned"

func _on_button_toggled(toggled_on):
	if toggled_on:
		button.text = "Press any key..."
		set_process_unhandled_key_input(true)

		# Disable focus navigation while rebinding
		button.focus_mode = Control.FOCUS_NONE

		for i in get_tree().get_nodes_in_group("HotkeyRebindButton"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		# Re-enable focus navigation
		button.focus_mode = Control.FOCUS_ALL

		for i in get_tree().get_nodes_in_group("HotkeyRebindButton"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)

		set_text_for_key()


func _unhandled_key_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		rebind_action_key(event)
		button.set_pressed_no_signal(false)  # Use this method to set the button state without emitting the signal
	
func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
	reset_buttons()

	SaveManager.data.options.keysbiding[action_name] = event.physical_keycode

func reset_buttons():
	for i in get_tree().get_nodes_in_group("HotkeyRebindButton"):
		i.button.toggle_mode = true
		i.set_process_unhandled_key_input(false)
