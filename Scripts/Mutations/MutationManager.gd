extends Node
class_name MutationManager

## Manages available and active mutations for the virus
## Handles mutation unlocking and activation

# ========================
# EXPORTS
# ========================
@export var available_mutations: Array[Mutation] = []

# ========================
# STATE
# ========================
var active_mutations: Array[Mutation] = []
var mutation_keybinds: Dictionary = {}  # Mutation -> String
var mutations_to_offer: Array[Mutation] = []

# ========================
# CONSTANTS
# ========================
const MAX_ACTIVE_MUTATIONS := 6
const MIN_MUTATIONS_FOR_CHOICE := 2

# ========================
# REFERENCES
# ========================
var virus_node: Node2D = null
var mutation_ui: Control = null

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	virus_node = get_parent()
	
	# Find UI reference (will be set by UI when it's ready)
	call_deferred("_find_ui")

func _find_ui() -> void:
	"""Find mutation UI in the scene tree"""
	mutation_ui = get_tree().get_first_node_in_group("mutation_ui")
	if not mutation_ui:
		push_warning("MutationManager: No mutation UI found in scene")

func _process(delta: float) -> void:
	_process_mutations(delta)
	_handle_mutation_inputs(delta)

# ========================
# MUTATION PROCESSING
# ========================
func _process_mutations(delta: float) -> void:
	"""Update all active mutations"""
	for mutation in active_mutations:
		if mutation.has_method("process"):
			mutation.process(virus_node, delta)

func _handle_mutation_inputs(delta: float) -> void:
	"""Handle input for all active mutations"""
	for mutation in active_mutations:
		var keybind: Variant = mutation_keybinds.get(mutation, "")
		if keybind.is_empty():
			continue
		
		# Handle different input types
		if mutation.has_method("apply") and Input.is_action_just_pressed(keybind):
			mutation.apply(virus_node)
			EventBus.mutation_ability_used.emit(mutation.name)
		
		if mutation.has_method("hold") and Input.is_action_pressed(keybind):
			mutation.hold(delta)
		
		if mutation.has_method("release") and Input.is_action_just_released(keybind):
			mutation.release(virus_node)

# ========================
# UNLOCKING
# ========================
func unlock_mutations() -> void:
	"""Check for newly available mutations based on virus level"""
	if not virus_node:
		return
	
	var current_level: int = virus_node.current_level
	
	for mutation in available_mutations:
		if mutation in active_mutations:
			continue
		
		if _is_mutation_available(mutation, current_level):
			if mutation not in mutations_to_offer:
				mutations_to_offer.append(mutation)
				EventBus.mutation_unlocked.emit(mutation)
	
	# Show UI when enough mutations are available
	if mutations_to_offer.size() >= MIN_MUTATIONS_FOR_CHOICE:
		_show_mutation_choice()

func _is_mutation_available(mutation: Mutation, level: int) -> bool:
	"""Check if mutation is available at current level"""
	return level >= mutation.level_min and level <= mutation.level_max

func _show_mutation_choice() -> void:
	"""Display mutation selection UI"""
	if not mutation_ui:
		push_warning("MutationManager: Cannot show UI - no UI reference")
		return
	
	mutations_to_offer.shuffle()
	EventBus.mutation_ui_opened.emit(mutations_to_offer)
	mutation_ui.setup(self)

# ========================
# ACTIVATION
# ========================
func activate_mutation(mutation: Mutation) -> void:
	"""Activate a chosen mutation"""
	if mutation in active_mutations:
		push_warning("MutationManager: Mutation already active")
		return
	
	# Add to active mutations
	active_mutations.append(mutation)
	
	# Call ready on mutation
	if mutation.has_method("ready"):
		mutation.ready(virus_node)
	
	# Assign keybind if needed
	if mutation.has_method("apply") and active_mutations.size() <= MAX_ACTIVE_MUTATIONS:
		var key_index := mutation_keybinds.size() + 1
		mutation_keybinds[mutation] = "mutation%d" % key_index
	
	# Remove from available pool
	available_mutations.erase(mutation)
	mutations_to_offer.clear()
	
	# Emit events
	EventBus.mutation_activated.emit(mutation)
	EventBus.mutation_ui_closed.emit(mutation)
	EventBus.emit_notification("Mutation Activated: %s" % mutation.name, "success")

# ========================
# COOLDOWN INFO (for UI)
# ========================
func get_cooldown_info() -> Dictionary:
	"""Returns cooldown information for UI display"""
	var info := {}
	
	for mutation in active_mutations:
		var keybind: Variant = mutation_keybinds.get(mutation, "")
		if keybind.is_empty():
			continue
		
		if mutation.has_method("get_cooldown") and mutation.has_method("get_max_cooldown"):
			info[keybind] = {
				"current": mutation.get_cooldown(),
				"max": mutation.get_max_cooldown()
			}
	
	return info
