extends Control

## Start Menu
## Main menu with play, options, and quit buttons

# ========================
# BUTTON CALLBACKS
# ========================

func _ready() -> void:
	EventBus.start_menu.emit() # Notify AudioManager to play menu music
	
func _on_start_button_pressed() -> void:
	"""Start the game"""
	get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn") 

func _on_options_button_pressed() -> void:
	"""Open options menu (to be implemented)"""
	# TODO: Implement options menu
	pass

func _on_quit_button_pressed() -> void:
	"""Quit the game"""
	get_tree().quit()


func _on_exit_button_pressed() -> void:
	pass # Replace with function body.
