extends Mutation
class_name OverchargeMutation

@export var speed_boost := 1.5
@export var duration := 1.5
@export var cooldown := 10.0

var is_active := false
var is_on_cooldown := false
var active_timer := 0.0
var cooldown_timer := 0.0

func apply(virus: Node2D) -> void:
    if is_on_cooldown or is_active:
        return
    
    is_active = true
    active_timer = duration
    virus.base_speed *= speed_boost
    EventBus.mutation_activated.emit(self)

func process(virus: Node2D, delta: float) -> void:
    if is_active:
        active_timer -= delta
        if active_timer <= 0:
            _end_boost(virus)
    
    if is_on_cooldown:
        cooldown_timer -= delta
        if cooldown_timer <= 0:
            is_on_cooldown = false
            EventBus.mutation_cooldown_finished.emit(name)

func _end_boost(virus: Node2D) -> void:
    is_active = false
    is_on_cooldown = true
    cooldown_timer = cooldown
    virus.base_speed /= speed_boost
    EventBus.mutation_cooldown_started.emit(name, cooldown)

func get_cooldown() -> float:
    return cooldown_timer if is_on_cooldown else 0.0

func get_max_cooldown() -> float:
    return cooldown