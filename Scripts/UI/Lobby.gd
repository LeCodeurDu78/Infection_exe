class_name Lobby
extends Control

const TEST_ROOM_PATH : String = "res://Scenes/World/TestRoom.tscn"
const VIRUS_TYPES    : Array[String] = ["Worm", "Trojan", "Ransomware", "Spyware"]

# Panneaux
@onready var _panel_main    : Control = $Panels/PanelMain
@onready var _panel_host    : Control = $Panels/PanelHost
@onready var _panel_join    : Control = $Panels/PanelJoin
@onready var _panel_waiting : Control = $Panels/PanelWaiting

# PanelMain
@onready var _btn_host : Button = $Panels/PanelMain/VBox/BtnHost
@onready var _btn_join : Button = $Panels/PanelMain/VBox/BtnJoin
@onready var _btn_quit : Button = $Panels/PanelMain/VBox/BtnQuit

# PanelHost — deux boutons distincts : configurer PUIS confirmer
@onready var _host_virus_options  : OptionButton  = $Panels/PanelHost/VBox/VirusOptions
@onready var _host_port_field     : LineEdit      = $Panels/PanelHost/VBox/PortField
@onready var _host_player_list    : VBoxContainer = $Panels/PanelHost/VBox/PlayerList
@onready var _host_status_label   : Label         = $Panels/PanelHost/VBox/StatusLabel
@onready var _btn_confirm_host    : Button        = $Panels/PanelHost/VBox/BtnConfirmHost
@onready var _btn_start_game      : Button        = $Panels/PanelHost/VBox/BtnStart
@onready var _btn_host_back       : Button        = $Panels/PanelHost/VBox/BtnBack

# PanelJoin
@onready var _join_virus_options  : OptionButton = $Panels/PanelJoin/VBox/VirusOptions
@onready var _join_ip_field       : LineEdit     = $Panels/PanelJoin/VBox/IpField
@onready var _join_port_field     : LineEdit     = $Panels/PanelJoin/VBox/PortField
@onready var _join_status_label   : Label        = $Panels/PanelJoin/VBox/StatusLabel
@onready var _btn_connect         : Button       = $Panels/PanelJoin/VBox/BtnConnect
@onready var _btn_join_back       : Button       = $Panels/PanelJoin/VBox/BtnBack

# PanelWaiting
@onready var _waiting_label    : Label  = $Panels/PanelWaiting/VBox/WaitingLabel
@onready var _btn_disconnect   : Button = $Panels/PanelWaiting/VBox/BtnDisconnect

# ============================================================
#  READY
# ============================================================
func _ready() -> void:
	_populate_virus_options(_host_virus_options)
	_populate_virus_options(_join_virus_options)
	_connect_buttons()
	_connect_event_bus()
	_show_panel("main")

# ============================================================
#  INIT
# ============================================================
func _populate_virus_options(option: OptionButton) -> void:
	option.clear()
	for v in VIRUS_TYPES:
		option.add_item(v)

func _connect_buttons() -> void:
	# PanelMain — navigation pure, aucune action réseau ici
	_btn_host.pressed.connect(func(): _show_panel("host"))
	_btn_join.pressed.connect(func(): _show_panel("join"))
	_btn_quit.pressed.connect(get_tree().quit)

	# PanelHost — 3 boutons distincts
	_btn_confirm_host.pressed.connect(_on_btn_confirm_host_pressed)   # lance le serveur
	_btn_start_game.pressed.connect(_on_btn_start_pressed)            # démarre la partie
	_btn_host_back.pressed.connect(func(): _cancel_and_back())

	# PanelJoin
	_btn_connect.pressed.connect(_on_btn_connect_pressed)
	_btn_join_back.pressed.connect(func(): _cancel_and_back())

	# PanelWaiting
	_btn_disconnect.pressed.connect(func(): _cancel_and_back())

func _connect_event_bus() -> void:
	EventBus.player_joined.connect(_on_player_joined)
	EventBus.player_left.connect(_on_player_left)
	EventBus.game_started.connect(_on_game_started)
	EventBus.connection_failed.connect(_on_connection_failed)
	EventBus.server_lost.connect(_on_server_lost)

# ============================================================
#  NAVIGATION
# ============================================================
func _show_panel(panel_name: String) -> void:
	_panel_main.visible    = panel_name == "main"
	_panel_host.visible    = panel_name == "host"
	_panel_join.visible    = panel_name == "join"
	_panel_waiting.visible = panel_name == "waiting"

func _cancel_and_back() -> void:
	NetworkManager.disconnect_game()
	_clear_player_list()
	_reset_host_ui()
	_show_panel("main")

func _reset_host_ui() -> void:
	_host_status_label.text  = ""
	_btn_confirm_host.visible = true
	_btn_confirm_host.disabled = false
	_btn_start_game.visible   = false
	_btn_start_game.disabled  = true
	_host_port_field.editable = true
	_host_virus_options.disabled = false

# ============================================================
#  BOUTONS
# ============================================================

# BtnHost (PanelMain) → navigation seulement, géré dans _connect_buttons

# BtnConfirmHost (PanelHost) → crée le serveur avec le port saisi
func _on_btn_confirm_host_pressed() -> void:
	var port : int = int(_host_port_field.text) if _host_port_field.text.is_valid_int() \
	                 else NetworkManager.DEFAULT_PORT
	NetworkManager.local_player_info["virus_type"] = VIRUS_TYPES[_host_virus_options.selected]

	var err := NetworkManager.host_game(port)
	if err != OK:
		_host_status_label.text = "Impossible de créer le serveur (port %d)" % port
		return

	# Verrouille la configuration une fois le serveur lancé
	_host_port_field.editable      = false
	_host_virus_options.disabled   = true
	_btn_confirm_host.visible      = false
	_btn_start_game.visible        = true
	_btn_start_game.disabled       = true

	_host_status_label.text = "En attente sur le port %d…" % port
	_refresh_player_list()

# BtnStart (PanelHost) → démarre la partie (host uniquement)
func _on_btn_start_pressed() -> void:
	if NetworkManager.get_player_count() < 1:
		_host_status_label.text = "Au moins 1 joueur requis."
		return
	NetworkManager.start_game()

# BtnConnect (PanelJoin) → rejoint le serveur
func _on_btn_connect_pressed() -> void:
	var ip   : String = _join_ip_field.text.strip_edges()
	var port : int    = int(_join_port_field.text) if _join_port_field.text.is_valid_int() \
	                    else NetworkManager.DEFAULT_PORT

	if ip.is_empty():
		_join_status_label.text = "Adresse IP requise."
		return

	NetworkManager.local_player_info["virus_type"] = VIRUS_TYPES[_join_virus_options.selected]
	_join_status_label.text = "Connexion à %s:%d…" % [ip, port]
	_btn_connect.disabled   = true
	_btn_join_back.disabled = true

	var err := NetworkManager.join_game(ip, port)
	if err != OK:
		_join_status_label.text = "Erreur réseau, réessaie."
		_btn_connect.disabled   = false
		_btn_join_back.disabled = false

# ============================================================
#  CALLBACKS EVENTBUS
# ============================================================
func _on_player_joined(peer_id: int, info: Dictionary) -> void:
	if multiplayer.is_server():
		# HOST : mise à jour de la liste et du bouton Start
		_refresh_player_list()
		var count := NetworkManager.get_player_count()
		_host_status_label.text  = "%d / %d joueur(s) connecté(s)" % [count, NetworkManager.MAX_PLAYERS]
		_btn_start_game.disabled = count < 1
	else:
		# CLIENT : on vient de recevoir la confirmation du serveur → PanelWaiting
		_waiting_label.text = "Connecté en tant que %s\n⏳ En attente du démarrage…" \
			% info.get("virus_type", "?")
		_show_panel("waiting")

func _on_player_left(_peer_id: int) -> void:
	if multiplayer.is_server():
		_refresh_player_list()

func _on_game_started() -> void:
	get_tree().change_scene_to_file(TEST_ROOM_PATH)

func _on_connection_failed() -> void:
	_join_status_label.text = "Connexion refusée."
	_btn_connect.disabled   = false
	_btn_join_back.disabled = false

func _on_server_lost() -> void:
	_cancel_and_back()

# ============================================================
#  LISTE DES JOUEURS (host uniquement)
# ============================================================
func _refresh_player_list() -> void:
	_clear_player_list()
	for peer_id in NetworkManager.players:
		var info  : Dictionary = NetworkManager.players[peer_id]
		var label := Label.new()
		var prefix := "👑 " if peer_id == 1 else ""
		label.text = "%s%s  [%s]  — id:%d" % [
			prefix,
			info.get("name", "?"),
			info.get("virus_type", "?"),
			peer_id
		]
		_host_player_list.add_child(label)

func _clear_player_list() -> void:
	for child in _host_player_list.get_children():
		child.queue_free()