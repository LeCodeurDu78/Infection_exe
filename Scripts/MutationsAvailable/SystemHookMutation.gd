extends Mutation
class_name SystemHookMutation

## System Hook - Reduces cooldowns of all active mutations
## Passive effect that permanently reduces cooldown times

# ========================
# EXPORTS
# ========================
@export var cooldown_reduction := 0.15  # 15% reduction

# ========================
# STATE
# ========================
var is_applied := false

# ========================
# LIFECYCLE
# ========================
func ready(virus: Node2D) -> void:
	"""Called when mutation is activated"""
	if is_applied:
		return
	
	is_applied = true
	_apply_cooldown_reduction(virus)
	EventBus.mutation_activated.emit(self)
	EventBus.emit_notification("⚙️ System Hook Active - Cooldowns Reduced!", "success")

func remove(virus: Node2D) -> void:
	"""Called when mutation is removed"""
	if not is_applied:
		return
	
	_remove_cooldown_reduction(virus)
	is_applied = false
	EventBus.mutation_deactivated.emit(self)

# ========================
# COOLDOWN MODIFICATION
# ========================
func _apply_cooldown_reduction(virus: Node2D) -> void:
	"""Reduce cooldowns of all active mutations"""
	if not virus.has_node("MutationManager"):
		return
	
	var mutation_manager = virus.get_node("MutationManager")
	
	for mutation in mutation_manager.active_mutations:
		if mutation == self:
			continue  # Don't modify self
		
		_reduce_mutation_cooldown(mutation)

func _remove_cooldown_reduction(virus: Node2D) -> void:
	"""Restore original cooldowns when removed"""
	if not virus.has_node("MutationManager"):
		return
	
	var mutation_manager = virus.get_node("MutationManager")
	
	for mutation in mutation_manager.active_mutations:
		if mutation == self:
			continue
		
		_restore_mutation_cooldown(mutation)

func _reduce_mutation_cooldown(mutation: Mutation) -> void:
	"""Apply cooldown reduction to a single mutation"""
	# Check if mutation has a cooldown property
	if mutation.get("cooldown") != null:
		var original_cooldown = mutation.get("cooldown")
		var new_cooldown = original_cooldown * (1.0 - cooldown_reduction)
		mutation.set("cooldown", new_cooldown)

func _restore_mutation_cooldown(mutation: Mutation) -> void:
	"""Restore original cooldown to a single mutation"""
	if mutation.get("cooldown") != null:
		var current_cooldown = mutation.get("cooldown")
		var original_cooldown = current_cooldown / (1.0 - cooldown_reduction)
		mutation.set("cooldown", original_cooldown)

# ========================
# PROCESS
# ========================
func process(virus: Node2D, _delta: float) -> void:
	"""Check for new mutations and apply reduction"""
	if not is_applied or not virus.has_node("MutationManager"):
		return
	
	var mutation_manager = virus.get_node("MutationManager")
	
	# Apply reduction to any newly activated mutations
	for mutation in mutation_manager.active_mutations:
		if mutation == self:
			continue
		
		# Check if this mutation already has reduced cooldown
		# (Simple check: if cooldown is not a multiple of base value)
		if mutation.get("cooldown") != null:
			_reduce_mutation_cooldown(mutation)