extends CanvasLayer

## Notification Manager
## Displays toast notifications to the player
## Automatically listens to EventBus.notification_shown

# ========================
# CONFIGURATION
# ========================
const NOTIFICATION_SCENE = preload("res://Scenes/UI/Notification.tscn")
const MAX_VISIBLE := 5
const SPACING := 10.0
const NOTIFICATION_WIDTH := 350.0

# ========================
# STATE
# ========================
var notification_queue: Array[Dictionary] = []
var active_notifications: Array[Control] = []

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	# Connect to EventBus
	EventBus.notification_shown.connect(_on_notification_requested)
	print("🔔 NotificationManager initialized")

# ========================
# NOTIFICATION HANDLING
# ========================
func _on_notification_requested(message: String, type: String) -> void:
	"""Called when EventBus emits notification_shown"""
	show_notification(message, type)

func show_notification(message: String, type: String = "info", duration: float = 3.0) -> void:
	"""Display a notification toast"""
	
	# Create notification
	var _notification = NOTIFICATION_SCENE.instantiate()
	add_child(_notification)
	active_notifications.append(_notification)
	_notification.setup(message, type)
	
	# Position notification
	_reposition_notifications()
	
	# Animate in
	_animate_in(_notification)
	
	# Auto-remove after duration
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(_notification):
		_remove_notification(_notification)

# ========================
# POSITIONING
# ========================
func _reposition_notifications() -> void:
	"""Stack notifications vertically"""
	var y_offset := 20.0
	var screen_width := get_viewport().get_visible_rect().size.x
	
	for notif in active_notifications:
		if not is_instance_valid(notif):
			continue
		
		# Position at top-right
		notif.position = Vector2(
			screen_width - NOTIFICATION_WIDTH - 20.0,
			y_offset
		)
		
		y_offset += notif.size.y + SPACING

# ========================
# ANIMATIONS
# ========================
func _animate_in(_notification: Control) -> void:
	"""Slide notification in from the right"""
	var start_pos := _notification.position
	_notification.position.x += NOTIFICATION_WIDTH
	_notification.modulate.a = 0.0
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_notification, "position", start_pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_notification, "modulate:a", 1.0, 0.2)

func _animate_out(_notification: Control) -> void:
	"""Fade notification out"""
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_notification, "modulate:a", 0.0, 0.2)
	tween.tween_property(_notification, "position:x", _notification.position.x + 50, 0.3)
	await tween.finished

# ========================
# REMOVAL
# ========================
func _remove_notification(_notification: Control) -> void:
	"""Remove a notification with animation"""
	if not is_instance_valid(_notification):
		return
	
	active_notifications.erase(_notification)
	
	# Animate out
	await _animate_out(_notification)
	
	if is_instance_valid(_notification):
		_notification.queue_free()
	
	# Reposition remaining notifications
	_reposition_notifications()

# ========================
# UTILITY
# ========================
func clear_all() -> void:
	"""Remove all active notifications"""
	for notif in active_notifications:
		if is_instance_valid(notif):
			notif.queue_free()
	active_notifications.clear()
