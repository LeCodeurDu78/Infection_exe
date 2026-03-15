extends Node

const DEFAULT_PORT : int = 7777
const MAX_PLAYERS  : int = 4

signal player_connected(peer_id: int, player_info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_disconnected()
signal connection_failed()
signal game_started()

var local_player_info : Dictionary = {
	"name"       : "Player",
	"virus_type" : "Worm",
	"peer_id"    : 1,
}

var players : Dictionary = {}

# ============================================================
#  READY
# ============================================================
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# ============================================================
#  API PUBLIQUE
# ============================================================
func host_game(port: int = DEFAULT_PORT) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err  := peer.create_server(port, MAX_PLAYERS)
	if err != OK:
		push_error("NetworkManager: impossible de créer le serveur (port %d)" % port)
		return err

	multiplayer.multiplayer_peer = peer

	# Le host s'enregistre lui-même en peer 1
	local_player_info["peer_id"] = 1
	players[1] = local_player_info.duplicate()
	player_connected.emit(1, players[1])
	EventBus.player_joined.emit(1, players[1])

	print("NetworkManager: serveur démarré sur le port %d" % port)
	return OK

func join_game(address: String = "127.0.0.1", port: int = DEFAULT_PORT) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err  := peer.create_client(address, port)
	if err != OK:
		push_error("NetworkManager: impossible de se connecter à %s:%d" % [address, port])
		return err

	multiplayer.multiplayer_peer = peer
	print("NetworkManager: connexion à %s:%d …" % [address, port])
	return OK

func disconnect_game() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	players.clear()

func start_game() -> void:
	if not multiplayer.is_server():
		push_warning("NetworkManager: seul le host peut démarrer la partie.")
		return
	_start_game.rpc()

# ============================================================
#  RPC
# ============================================================

## Envoyé par un peer pour annoncer ses infos à tous.
## Seul le SERVEUR reçoit ce message (voir _on_connected_to_server).
@rpc("any_peer", "reliable")
func _register_player(info: Dictionary) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	info["peer_id"] = sender_id
	players[sender_id] = info
	player_connected.emit(sender_id, info)
	EventBus.player_joined.emit(sender_id, info)
	print("NetworkManager: joueur enregistré → ", info)

## Envoyé par le serveur à un client pour lui donner les infos du host.
## Séparé de _register_player pour éviter toute confusion d'identité.
@rpc("authority", "reliable")
func _send_host_info(info: Dictionary) -> void:
	var host_info := info.duplicate()
	host_info["peer_id"] = 1
	players[1] = host_info
	player_connected.emit(1, host_info)
	EventBus.player_joined.emit(1, host_info)
	print("NetworkManager: infos du host reçues → ", host_info)

## Reçu par tous les peers : la partie commence.
@rpc("authority", "call_local", "reliable")
func _start_game() -> void:
	game_started.emit()
	EventBus.game_started.emit()

# ============================================================
#  CALLBACKS RÉSEAU GODOT
# ============================================================

## Appelé quand un peer se connecte.
## peer_connected fire sur TOUS les peers — on filtre pour n'agir que sur le serveur.
func _on_peer_connected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	print("NetworkManager: nouveau client connecté → %d" % peer_id)
	# Envoie les infos du host au nouveau client
	_send_host_info.rpc_id(peer_id, local_player_info)

func _on_peer_disconnected(peer_id: int) -> void:
	print("NetworkManager: peer déconnecté → %d" % peer_id)
	players.erase(peer_id)
	player_disconnected.emit(peer_id)
	EventBus.player_left.emit(peer_id)

## Appelé sur le CLIENT une fois connecté au serveur.
func _on_connected_to_server() -> void:
	var my_id := multiplayer.get_unique_id()
	local_player_info["peer_id"] = my_id
	# Envoie ses infos au serveur uniquement (rpc_id 1 = serveur)
	_register_player.rpc_id(1, local_player_info)
	print("NetworkManager: connecté au serveur. Mon peer_id = %d" % my_id)

func _on_connection_failed() -> void:
	push_warning("NetworkManager: échec de la connexion.")
	multiplayer.multiplayer_peer = null
	connection_failed.emit()
	EventBus.connection_failed.emit()

func _on_server_disconnected() -> void:
	push_warning("NetworkManager: serveur déconnecté.")
	players.clear()
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()
	EventBus.server_lost.emit()

# ============================================================
#  UTILITAIRES
# ============================================================
func is_online() -> bool:
	return multiplayer.multiplayer_peer != null

func get_local_peer_id() -> int:
	return multiplayer.get_unique_id()

func get_player_count() -> int:
	return players.size()