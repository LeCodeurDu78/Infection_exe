extends Control

## Options Menu
## Options menu with resoliution, volume, and keybindings options

# ========================
# GRAPHICS
# ========================
func _ready() -> void:
	# Set the initial values of the options based on the saved data
	var window_mode_index = SaveManager.data.options.get("window_mode", 0)
	var resolution_index = SaveManager.data.options.get("resolution", 0)
	var vsync_index = SaveManager.data.options.get("vsync", 0)

	var monitor_fps = DisplayServer.screen_get_refresh_rate()
	if monitor_fps < 0:
		monitor_fps = 60
	var max_fps = SaveManager.data.options.get("max_fps", monitor_fps)

	var master_volume = SaveManager.data.options.get("master_volume", 50)
	var music_volume = SaveManager.data.options.get("music_volume", 50)
	var sfx_volume = SaveManager.data.options.get("sfx_volume", 50)

	$TabContainer/Graphics/MarginContainer/VBoxContainer/WindowMode/OptionButton.selected = window_mode_index
	_on_window_mode_selected(window_mode_index) # Apply the window mode on startup

	$TabContainer/Graphics/MarginContainer/VBoxContainer/Resolution/OptionButton.selected = resolution_index
	_on_resolution_selected(resolution_index) # Apply the resolution on startup

	$TabContainer/Graphics/MarginContainer/VBoxContainer/Vsync/OptionButton.selected = vsync_index
	_on_vsync_selected(vsync_index)

	$TabContainer/Graphics/MarginContainer/VBoxContainer/MaxFPS/OptionSpin.value = float(max_fps)
	set_max_fps(float(max_fps)) # Apply the max FPS on startup

	$TabContainer/Sounds/MasterSlider.value = master_volume
	_on_master_volume_changed(master_volume) # Apply the master volume on startup

	$TabContainer/Sounds/MusicSlider.value = music_volume
	_on_music_volume_changed(music_volume) # Apply the music volume on startup

	$TabContainer/Sounds/SFXSlider.value = sfx_volume
	_on_sfx_volume_changed(sfx_volume) # Apply the SFX volume on startup

func _on_window_mode_selected(index: int) -> void:
	"""Change the window mode based on the selected index"""
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

	SaveManager.data.options["window_mode"] = index
	SaveManager.save_data() # Save the options data after changing the window mode

func _on_resolution_selected(index: int) -> void:
	"""Change the resolution based on the selected index"""
	var res := Vector2i(0, 0)
	
	match index:
		0:
			res = Vector2i(1920, 1080)
		1:
			res = Vector2i(1280, 720)
		2:
			res = Vector2i(1152, 648)

	DisplayServer.window_set_size(res)
	SaveManager.data.options["resolution"] = index
	SaveManager.save_data() # Save the options data after changing the resolution

func _on_vsync_selected(index: int) -> void:
	if index == 0: # Disabled (default)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
	SaveManager.data.options["vsync"] = index
	SaveManager.save_data()

func set_max_fps(_value: float) -> void:
	var value = int(_value)
	Engine.max_fps = value if value < 500 else 0
	SaveManager.data.options["max_fps"] = Engine.max_fps if value < 500 else 500
	SaveManager.save_data()

# ========================
# SOUND 
# ========================

func _on_master_volume_changed(value: float) -> void:
	AudioManager.set_master_volume(value / 100.0) # Adjust master volume in AudioManager
	SaveManager.data.options["master_volume"] = value
	SaveManager.save_data() # Save the options data after changing the master volume

func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value / 100.0) # Adjust music volume in AudioManager
	SaveManager.data.options["music_volume"] = value
	SaveManager.save_data() # Save the options data after changing the music volume

func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value / 100.0) # Adjust SFX volume in AudioManager
	SaveManager.data.options["sfx_volume"] = value
	SaveManager.save_data() # Save the options data after changing the SFX volume


func _on_exit_button_pressed() -> void:
	"""Exit the Option Menu and return to the Start Menu"""
	if get_parent().has_node("Container"):
		get_parent().get_node("Container").visible = true

	visible = false
