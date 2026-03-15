class_name VirusBase
extends CharacterBody2D

# ============================================================
#  SIGNALS
# ============================================================
signal died(virus: VirusBase)
signal health_changed(current: float, maximum: float)
signal ability_used()
signal ability_ready()

# ============================================================
#  EXPORTED STATS  (surchargeables dans les classes enfants)
# ============================================================
@export_group("Stats")
@export var base_max_hp    : float = 100.0
@export var base_speed     : float = 150.0
@export var base_damage    : float = 10.0
@export var ability_cooldown: float = 10.0

@export_group("Info")
@export var virus_name     : String = "Virus"
@export var virus_color    : Color  = Color.GREEN

# ============================================================
#  STATE  (certaines propriétés sont synchronisées réseau)
# ============================================================
var current_hp      : float   = 100.0
var is_dead         : bool    = false
var facing_direction: Vector2 = Vector2.RIGHT

# Cooldown de l'abilité (traité en local, pas besoin de sync)
var _ability_timer  : float   = 0.0
var _ability_ready  : bool    = true

# Vecteur d'entrée — calculé localement par l'authorité
var _input_vector   : Vector2 = Vector2.ZERO

# ============================================================
#  NŒUDS  (doivent exister dans la scène enfant)
# ============================================================
@onready var _sprite           : Sprite2D             = $Sprite2D
@onready var _animation_player : AnimationPlayer      = $AnimationPlayer
@onready var _hit_box          : Area2D               = $HitBox
@onready var _hurt_box         : Area2D               = $HurtBox
@onready var _sync             : MultiplayerSynchronizer = $MultiplayerSynchronizer

# ============================================================
#  READY
# ============================================================
func _ready() -> void:
	current_hp = base_max_hp

	# Seul le peer "authorité" gère les entrées et la physique.
	# Les autres reçoivent les données via MultiplayerSynchronizer.
	set_physics_process(is_multiplayer_authority())

	# Connexion du HurtBox : détecte les projectiles ennemis
	if _hurt_box:
		_hurt_box.area_entered.connect(_on_hurt_box_area_entered)

# ============================================================
#  PHYSIQUE  (appelé uniquement chez l'authorité)
# ============================================================
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_handle_movement()
	_handle_animation()
	_tick_ability_cooldown(delta)

	# Action spéciale
	if Input.is_action_just_pressed("ability"):
		use_ability()

func _handle_movement() -> void:
	_input_vector = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)
	velocity = _input_vector * base_speed
	move_and_slide()

	if _input_vector != Vector2.ZERO:
		facing_direction = _input_vector.normalized()

func _handle_animation() -> void:
	if not is_instance_valid(_animation_player):
		return
	if _input_vector == Vector2.ZERO:
		_animation_player.play("idle")
	else:
		_animation_player.play("walk")

func _tick_ability_cooldown(delta: float) -> void:
	if _ability_ready:
		return
	_ability_timer -= delta
	if _ability_timer <= 0.0:
		_ability_ready = true
		ability_ready.emit()

# ============================================================
#  DÉGÂTS / SOINS  (appelés uniquement sur l'authorité)
# ============================================================
func take_damage(amount: float) -> void:
	if is_dead or not is_multiplayer_authority():
		return
	current_hp = clampf(current_hp - amount, 0.0, base_max_hp)
	health_changed.emit(current_hp, base_max_hp)
	EventBus.virus_hp_changed.emit(get_multiplayer_authority(), current_hp, base_max_hp)
	EventBus.virus_damaged.emit(get_multiplayer_authority(), amount, current_hp)
	_on_damaged()
	if current_hp <= 0.0:
		_trigger_death()

func heal(amount: float) -> void:
	if is_dead:
		return
	current_hp = clampf(current_hp + amount, 0.0, base_max_hp)
	health_changed.emit(current_hp, base_max_hp)

# ============================================================
#  MORT
# ============================================================
func _trigger_death() -> void:
	is_dead = true
	set_physics_process(false)
	died.emit(self)
	EventBus.virus_died.emit(get_multiplayer_authority())
	_play_death_animation()

func _play_death_animation() -> void:
	if not is_instance_valid(_animation_player):
		queue_free()
		return
	if _animation_player.has_animation("death"):
		_animation_player.play("death")
		await _animation_player.animation_finished
	queue_free()

# ============================================================
#  ABILITÉ  (à surcharger dans chaque virus)
# ============================================================
func use_ability() -> void:
	if not _ability_ready:
		return
	_ability_ready = false
	_ability_timer = ability_cooldown
	ability_used.emit()
	EventBus.virus_ability_used.emit(get_multiplayer_authority(), virus_name)
	# Logique concrète dans les classes enfants

# ============================================================
#  CALLBACKS INTERNES  (overridables)
# ============================================================
func _on_damaged() -> void:
	# Feedback visuel : flash rouge (override si besoin)
	if is_instance_valid(_sprite):
		_sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		_sprite.modulate = virus_color

func _on_hurt_box_area_entered(area: Area2D) -> void:
	# Le HurtBox réagit aux HitBox des projectiles ennemis.
	# Les projectiles doivent exposer une variable "damage".
	if area.has_meta("damage"):
		take_damage(area.get_meta("damage"))

# ============================================================
#  UTILITAIRES RÉSEAU
# ============================================================

## Retourne true si ce virus appartient au joueur local.
func is_local_player() -> bool:
	return is_multiplayer_authority()

## Assigne l'authorité au peer donné (appelé par le serveur au spawn).
func assign_to_peer(peer_id: int) -> void:
	set_multiplayer_authority(peer_id)
	set_physics_process(is_multiplayer_authority())
