extends Control

## Pause Menu
## Pause menu with resume, options, and Save and Quit buttons

# ========================
# BUTTON CALLBACKS
# ========================
func _ready() -> void:
	EventBus.pause_menu.connect(_on_pause_menu_opened)

func _on_pause_menu_opened() -> void:
	"""Called when pause menu is opened"""
	print("test")
	visible = true
	get_tree().paused = true

func _on_resume_button_pressed() -> void:
	"""Resume the game"""
	get_tree().paused = false
	visible = false
	
func _on_options_button_pressed() -> void:
	$OptionsMenu.visible = true
	$Container.visible = false
	
func _on_save_and_quit_button_pressed() -> void:
	"""Save and exit the game"""
	# TODO: Il faut sauvgarder la position, les mutations, le niveaux, etc.
	SaveManager.save_game()
	get_tree().quit()
