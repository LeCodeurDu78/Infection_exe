extends Control

## Start Menu
## Main menu with play, options, and quit buttons

# ========================
# BUTTON CALLBACKS
# ========================
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
