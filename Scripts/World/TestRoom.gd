class_name TestRoom
extends Node2D

# ============================================================
#  TestRoom
#
#  Objectif : valider en réseau que —
#    ✔ Les virus spawnent au bon endroit pour chaque joueur
#    ✔ Le mouvement se synchronise entre peers
#    ✔ Les collisions avec les murs fonctionnent
#    ✔ L'abilité du Worm (leurre) s'affiche chez tous
#
#  Pas d'ennemi, pas de génération procédurale : juste un
#  espace jouable avec des murs et des spawn points.
# ============================================================

const VIRUS_SCENES : Dictionary = {
	"Worm"       : "res://Scenes/Entities/Viruses/Worm.tscn",
	"Trojan"     : "res://Scenes/Entities/Viruses/Trojan.tscn",
	"Ransomware" : "res://Scenes/Entities/Viruses/Ransomware.tscn",
	"Spyware"    : "res://Scenes/Entities/Viruses/Spyware.tscn",
}

# Fallback si le virus demandé n'a pas encore sa scène
const FALLBACK_VIRUS : String = "res://Scenes/Entities/Viruses/Worm.tscn"

# ============================================================
#  NŒUDS
# ============================================================
@onready var _virus_container : Node2D      = $Entities/Viruses
@onready var _spawn_points    : Node2D      = $SpawnPoints
@onready var _hud             : CanvasLayer = $HUD
@onready var _debug_label     : Label       = $HUD/DebugLabel
@onready var _btn_back        : Button      = $HUD/BtnBackToLobby

# ============================================================
#  READY
# ============================================================
func _ready() -> void:
	_btn_back.pressed.connect(_on_back_pressed)
	# Seul le serveur spawne les virus (puis les synchronise)
	if multiplayer.is_server():
		_spawn_all_viruses()

	EventBus.virus_died.connect(_on_virus_died)

# ============================================================
#  SPAWN
# ============================================================
func _spawn_all_viruses() -> void:
	var spawn_nodes : Array[Node] = _spawn_points.get_children()
	var player_ids  : Array       = NetworkManager.players.keys()

	for i in player_ids.size():
		var peer_id   : int        = player_ids[i]
		var info      : Dictionary = NetworkManager.players[peer_id]
		var virus_type: String     = info.get("virus_type", "Worm")
		var spawn_pos : Vector2    = Vector2.ZERO

		# Distribue les spawn points cycliquement
		if i < spawn_nodes.size():
			spawn_pos = spawn_nodes[i].global_position

		_spawn_virus.rpc(peer_id, virus_type, spawn_pos)

## Exécuté sur TOUS les peers — instancie et configure le virus.
@rpc("authority", "call_local", "reliable")
func _spawn_virus(peer_id: int, virus_type: String, spawn_pos: Vector2) -> void:
	var scene_path : String = VIRUS_SCENES.get(virus_type, FALLBACK_VIRUS)

	# Charge en fallback si la scène n'existe pas encore
	var packed : PackedScene
	if ResourceLoader.exists(scene_path):
		packed = load(scene_path)
	else:
		push_warning("TestRoom: scène '%s' introuvable, fallback Worm." % scene_path)
		packed = load(FALLBACK_VIRUS)

	var virus : VirusBase = packed.instantiate()
	virus.name = "Virus_%d" % peer_id        # nom unique pour le MultiplayerSpawner
	virus.global_position = spawn_pos
	_virus_container.add_child(virus)

	# Assigne l'authorité au peer propriétaire
	virus.assign_to_peer(peer_id)

	_update_debug(peer_id, virus_type)

# ============================================================
#  DEBUG HUD
# ============================================================
func _update_debug(peer_id: int, virus_type: String) -> void:
	if not is_instance_valid(_debug_label):
		return
	var existing := _debug_label.text
	_debug_label.text = existing + "\n🦠 peer %d → %s" % [peer_id, virus_type]

func _on_virus_died(peer_id: int) -> void:
	if is_instance_valid(_debug_label):
		_debug_label.text += "\n💀 peer %d est mort" % peer_id

func _on_back_pressed() -> void:
	NetworkManager.disconnect_game()
	get_tree().change_scene_to_file("res://Scenes/UI/Lobby.tscn")
