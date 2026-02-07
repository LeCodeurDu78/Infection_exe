extends Control

## Mutation Selection UI
## Displays mutation choices and handles player selection

# ========================
# CONSTANTS
# ========================
const MAX_CHOICES := 3

# ========================
# REFERENCES
# ========================
var mutation_manager: MutationManager = null

# ========================
# NODE REFERENCES
# ========================
@onready var mutation_button_1: Button = $MutationButton1
@onready var mutation_button_2: Button = $MutationButton2
@onready var mutation_button_3: Button = $MutationButton3

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	add_to_group("mutation_ui")
	visible = false
	
# ========================
# SETUP
# ========================
func setup(manager: MutationManager) -> void:
	"""Display mutation choices to player"""
	mutation_manager = manager
	
	if not mutation_manager or mutation_manager.mutations_to_offer.is_empty():
		push_error("MutationUI: Invalid setup - no manager or mutations")
		return
	
	_populate_buttons()
	_show_ui()

func _populate_buttons() -> void:
	"""Fill buttons with mutation names"""
	var mutations := mutation_manager.mutations_to_offer
	
	# Button 1
	if mutations.size() > 0 and mutation_button_1:
		mutation_button_1.text = mutations[0].name
		mutation_button_1.visible = true
	
	# Button 2
	if mutations.size() > 1 and mutation_button_2:
		mutation_button_2.text = mutations[1].name
		mutation_button_2.visible = true
	
	# Button 3
	if mutations.size() > 2 and mutation_button_3:
		mutation_button_3.text = mutations[2].name
		mutation_button_3.visible = true
	else:
		mutation_button_3.visible = false

func _show_ui() -> void:
	"""Show UI and pause game"""
	visible = true
	get_tree().paused = true

func _hide_ui() -> void:
	"""Hide UI and unpause game"""
	visible = false
	get_tree().paused = false

# ========================
# SELECTION
# ========================
func _on_mutation_selected(mutation_index: int) -> void:
	"""Handle mutation selection"""
	if not mutation_manager:
		return
	
	var mutations := mutation_manager.mutations_to_offer
	if mutation_index < 0 or mutation_index >= mutations.size():
		push_error("MutationUI: Invalid mutation index: %d" % mutation_index)
		return
	
	var selected_mutation := mutations[mutation_index]
	mutation_manager.activate_mutation(selected_mutation)
	_hide_ui()

# ========================
# BUTTON CALLBACKS
# ========================
func _on_mutation_1_pressed() -> void:
	_on_mutation_selected(0)

func _on_mutation_2_pressed() -> void:
	_on_mutation_selected(1)

func _on_mutation_3_pressed() -> void:
	_on_mutation_selected(2)
