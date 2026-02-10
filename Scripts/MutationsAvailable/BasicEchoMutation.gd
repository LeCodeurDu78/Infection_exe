extends Mutation
class_name BasicEchoMutation

@export var cooldown := 15.0
@export var reveal_duration := 4.0
@export var reveal_radius := 1000.0

var is_on_cooldown := false
var cooldown_timer := 0.0

func apply(virus: Node2D) -> void:
    if is_on_cooldown:
        return
    
    _reveal_enemies(virus)
    is_on_cooldown = true
    cooldown_timer = cooldown
    EventBus.mutation_activated.emit(self)
    EventBus.mutation_cooldown_started.emit(name, cooldown)

func _reveal_enemies(virus: Node2D) -> void:
    # Utilise virus.get_tree() au lieu de get_tree()
    var antiviruses = virus.get_tree().get_nodes_in_group("antivirus")
    for av in antiviruses:
        if virus.global_position.distance_to(av.global_position) < reveal_radius:
            _highlight_enemy(virus, av, reveal_duration)

func _highlight_enemy(virus: Node2D, enemy: Node2D, duration: float) -> void:
    # Sauvegarde la couleur originale
    var original_color = enemy.modulate
    
    # Applique l'effet visuel
    enemy.modulate = Color(1, 1, 0) # Jaune
    
    # Utilise virus.get_tree() pour créer le timer
    await virus.get_tree().create_timer(duration).timeout
    
    # Restore la couleur uniquement si l'ennemi existe encore
    if is_instance_valid(enemy):
        enemy.modulate = original_color

func process(_virus: Node2D, delta: float) -> void:
    if is_on_cooldown:
        cooldown_timer -= delta
        if cooldown_timer <= 0:
            is_on_cooldown = false
            EventBus.mutation_cooldown_finished.emit(name)

func get_cooldown() -> float:
    return cooldown_timer if is_on_cooldown else 0.0

func get_max_cooldown() -> float:
    return cooldown