class_name Worm
extends VirusBase

# ============================================================
#  WORM — Tank / Explorateur
#
#  Concept : Le Worm se duplique pour créer un leurre temporaire
#  qui attire l'attention des ennemis. Il a plus de HP mais est
#  plus lent que les autres virus.
#
#  ABILITÉ : Replicate
#    → Spawne un clone fantôme à la position actuelle.
#    → Le clone reste immobile 5 secondes et attire les ennemis.
#    → Cooldown : 15 secondes.
# ============================================================

# ============================================================
#  CONSTANTES
# ============================================================
const DECOY_DURATION   : float = 5.0
const DECOY_SCENE_PATH : String = "res://Scenes/Entities/Viruses/WormDecoy.tscn"

# ============================================================
#  READY — surcharge des stats de base
# ============================================================
func _ready() -> void:
	# Stats spécifiques au Worm
	base_max_hp      = 150.0   # tankier que la moyenne
	base_speed       = 120.0   # plus lent
	base_damage      = 8.0
	ability_cooldown = 15.0

	virus_name  = "Worm"
	virus_color = Color(0.2, 1.0, 0.2)   # vert vif

	# Appel du _ready() parent après avoir défini les stats
	super._ready()

# ============================================================
#  ABILITÉ : Replicate
# ============================================================
func use_ability() -> void:
	if not _ability_ready or not is_multiplayer_authority():
		return

	# Consomme le cooldown (logique parente)
	super.use_ability()

	# Envoie le RPC à tous les peers pour spawner le leurre
	_spawn_decoy.rpc(global_position)

# ============================================================
#  RPC : spawn du leurre (exécuté sur TOUS les peers)
# ============================================================
@rpc("authority", "call_local", "reliable")
func _spawn_decoy(spawn_pos: Vector2) -> void:
	var decoy_scene := load(DECOY_SCENE_PATH) as PackedScene
	if decoy_scene == null:
		push_warning("Worm: WormDecoy.tscn introuvable → %s" % DECOY_SCENE_PATH)
		return

	var decoy: Node2D = decoy_scene.instantiate()
	get_parent().add_child(decoy)
	decoy.global_position = spawn_pos

	# Le leurre se détruit automatiquement après DECOY_DURATION
	await get_tree().create_timer(DECOY_DURATION).timeout
	if is_instance_valid(decoy):
		decoy.queue_free()

# ============================================================
#  OVERRIDE VISUEL : couleur du flash de dégâts
# ============================================================
func _on_damaged() -> void:
	# Flash blanc pour le Worm (plus lisible sur son sprite vert)
	if is_instance_valid(_sprite):
		_sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		_sprite.modulate = virus_color
