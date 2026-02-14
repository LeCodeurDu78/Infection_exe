extends Control

## Start Menu
## Main menu with play, options, and quit buttons

# ========================
# BUTTON CALLBACKS
# ========================
@onready var options = preload("res://Scenes/UI/OptionsMenu.tscn")

func _ready() -> void:
	EventBus.start_menu.emit() # Notify AudioManager to play menu music
	
func _on_start_button_pressed() -> void:
	"""Start the game"""
	 # Notify GameManager to start the game
	ZoneManager.start_zone("files")

func _on_options_button_pressed() -> void:
	SaveManager.load_data()
	var panel = options.instantiate()
	add_child(panel)
	$Container.visible = false

func _on_achievements_button_pressed() -> void:
	$AchievementPanel.show_panel()
	$Container.visible = false
	
func _on_exit_button_pressed() -> void:
	"""Quit the game"""
	get_tree().quit()
