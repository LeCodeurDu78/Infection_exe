extends Control

## Zone Selector UI
## Shows available zones and allows player to select next zone

# ========================
# NODES
# ========================
@onready var zones_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/ZonesContainer
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/Header/Title
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/Header/CloseButton

# ========================
# ZONE BUTTON SCENE
# ========================
const ZONE_BUTTON_SCENE = preload("res://Scenes/UI/ZoneButton.tscn")

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)

# ========================
# DISPLAY
# ========================
func show_selector() -> void:
	"""Show zone selector"""
	visible = true
	_populate_zones()

func hide_selector() -> void:
	"""Hide zone selector"""
	visible = false

func _populate_zones() -> void:
	"""Populate with available zones"""
	# Clear existing buttons
	for child in zones_container.get_children():
		child.queue_free()
	
	# Get all zones
	for zone_id in ["files", "processes", "network", "admin", "core"]:
		var zone = ZoneManager.get_zone(zone_id)
		if not zone:
			continue
		
		# Create button
		var button = ZONE_BUTTON_SCENE.instantiate()
		zones_container.add_child(button)
		button.setup(zone)
		button.zone_selected.connect(_on_zone_selected)

# ========================
# SIGNALS
# ========================
func _on_zone_selected(zone_id: String) -> void:
	"""Zone button clicked"""
	ZoneManager.start_zone(zone_id)
	hide_selector()

func _on_close_pressed() -> void:
	hide_selector()
