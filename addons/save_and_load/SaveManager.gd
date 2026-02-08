extends Node

# Data
@export var data = {
	"options": {
		"window_mode": 0, # 0: Fullscreen, 1: Windowed, 2: Borderless Fullscreen, 3: Borderless Windowed
		"resolution": 0, # 0: 1920x1080, 1: 1280x720, 2: 1152x648
		"master_volume": 50,
		"music_volume": 50,
		"sfx_volume": 50,
		"keysbiding": {
			"move_up": 0,
			"move_down": 0,
			"move_left": 0,
			"move_right": 0,
			"mutation1": 0,
			"mutation2": 0,
			"mutation3": 0,
			"mutation4": 0,
			"mutation5": 0,
		},
	}
}
const save_path = "user://data"

# Capabilities
@export var autoload = false
@export var autosave = false
@export var interval = 60

# Developer Options
var encryption = false ## Never change if the project was executed before!

func _ready() -> void:
	load_data()
	if autosave:
		$Timer.wait_time = interval
		$Timer.start()

func save_data() -> void:
	var file
	if encryption:
		file = FileAccess.open_encrypted_with_pass(save_path, FileAccess.WRITE, "SyntaxxError")
	else:
		file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_data() -> void:
	if FileAccess.file_exists(save_path):
		var file
		if encryption:
			if not FileAccess.file_exists(save_path):
				save_data() 
			file = FileAccess.open_encrypted_with_pass(save_path, FileAccess.READ, "SyntaxxError")
		else:
			if not FileAccess.file_exists(save_path):
				save_data() 
			file = FileAccess.open(save_path, FileAccess.READ)
		data = file.get_var()
		file.close()

func _on_timer_timeout() -> void:
	save_data()
