extends Control

## Options Menu
## Options menu with resoliution, volume, and keybindings options

@onready var resolutionOption: OptionButton = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/GraphicsSection/Resolution/OptionButton
@onready var windowModeOption: OptionButton = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/GraphicsSection/WindowMode/OptionButton
@onready var maxFPSOption: SpinBox = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/GraphicsSection/MaxFPS/OptionButton
@onready var vsyncOption: OptionButton = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/GraphicsSection/VSync/OptionButton
@onready var particlesOption: OptionButton = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/GraphicsSection/Particles/OptionButton
@onready var screenShakeOption: OptionButton = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/GraphicsSection/ScreenShake/OptionButton

@onready var masterOption: Slider = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/AudioSection/MasterVolume/Slider
@onready var musicOption: Slider = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/AudioSection/MusicVolume/Slider
@onready var sfxOption: Slider = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/AudioSection/SFXVolume/Slider

@onready var audioSection: VBoxContainer = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/AudioSection
@onready var graphicsSection: VBoxContainer = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/GraphicsSection
@onready var controlsSection: VBoxContainer = $MarginContainer/MainPanel/MarginContainer/VBoxContainer/ContentPanel/MarginContainer/Content/ControlsSection

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

	var master_volume = SaveManager.data.options.get("master_volume", 100)
	var music_volume = SaveManager.data.options.get("music_volume", 80)
	var sfx_volume = SaveManager.data.options.get("sfx_volume", 90)

	resolutionOption.selected = resolution_index
	windowModeOption.selected = window_mode_index
	vsyncOption.selected = vsync_index
	maxFPSOption.value = float(max_fps)

	masterOption.value = master_volume
	musicOption.value = music_volume
	sfxOption.value = sfx_volume

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

func _on_vsync_selected(index: int) -> void:
	if index == 0: # Disabled (default)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
	SaveManager.data.options["vsync"] = index

func set_max_fps(_value: float) -> void:
	var value = int(_value)
	Engine.max_fps = value if value < 500 else 0
	SaveManager.data.options["max_fps"] = Engine.max_fps if value < 500 else 500

# ========================
# SOUND 
# ========================

func _on_master_volume_changed(value: float) -> void:
	AudioManager.set_master_volume(value / 100.0) # Adjust master volume in AudioManager
	SaveManager.data.options["master_volume"] = value

func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value / 100.0) # Adjust music volume in AudioManager
	SaveManager.data.options["music_volume"] = value

func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value / 100.0) # Adjust SFX volume in AudioManager
	SaveManager.data.options["sfx_volume"] = value

func _on_audio_tab_pressed():
	audioSection.visible = true
	graphicsSection.visible = false
	controlsSection.visible = false

func _on_graphics_tab_pressed():
	audioSection.visible = false
	graphicsSection.visible = true
	controlsSection.visible = false

func _on_controls_tab_pressed():
	audioSection.visible = false
	graphicsSection.visible = false
	controlsSection.visible = true

func _on_save_button_pressed() -> void:
	"""Save the current options data and exit the Option Menu"""
	SaveManager.save_data()
	EventBus.emit_notification("Options Saved", "success") 

func _on_exit_button_pressed() -> void:
	"""Exit the Option Menu and return to the Start Menu"""
	if get_parent().has_node("Container"):
		get_parent().get_node("Container").visible = true

	queue_free()
