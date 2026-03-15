extends Node

# ============================================================
#  EventBus  (Autoload)
#
#  Principe : aucun nœud ne garde de référence directe sur un
#  autre. Tous les événements globaux transitent ici.
#  Usage :
#    Émettre  → EventBus.player_died.emit(peer_id)
#    Écouter  → EventBus.player_died.connect(_on_player_died)
# ============================================================


# ============================================================
#  RÉSEAU / SESSION
# ============================================================

## Un joueur a rejoint le lobby.
signal player_joined(peer_id: int, player_info: Dictionary)

## Un joueur a quitté la session.
signal player_left(peer_id: int)

## Le host a lancé la partie.
signal game_started()

## La connexion au serveur a échoué.
signal connection_failed()

## Le serveur s'est déconnecté de façon inattendue.
signal server_lost()


# ============================================================
#  CYCLE DE JEU
# ============================================================

## Un nouvel étage (Level) est prêt à être joué.
signal level_ready(level_index: int)

## Tous les joueurs ont franchi la sortie de l'étage.
signal level_completed(level_index: int)

## La run entière est terminée (victoire ou défaite).
signal run_ended(victory: bool)

## Le boss de l'étage est apparu.
signal boss_spawned(boss_name: String)

## Le boss de l'étage est mort.
signal boss_defeated(boss_name: String)


# ============================================================
#  JOUEURS / VIRUS
# ============================================================

## Un virus a subi des dégâts.
signal virus_damaged(peer_id: int, amount: float, remaining_hp: float)

## Un virus est mort.
signal virus_died(peer_id: int)

## Un virus a utilisé son abilité.
signal virus_ability_used(peer_id: int, ability_name: String)

## Un virus a ramassé un item.
signal virus_picked_up_item(peer_id: int, item_type: String)

## Les HP d'un virus ont changé (pour le HUD).
signal virus_hp_changed(peer_id: int, current: float, maximum: float)


# ============================================================
#  SALLES (ROOMS)
# ============================================================

## Le joueur local entre dans une nouvelle salle.
signal room_entered(room_id: int)

## Une salle est entièrement nettoyée (tous les ennemis morts).
signal room_cleared(room_id: int)

## Les portes d'une salle se verrouillent (combat en cours).
signal room_locked(room_id: int)

## Les portes d'une salle s'ouvrent.
signal room_unlocked(room_id: int)


# ============================================================
#  ENNEMIS
# ============================================================

## Un ennemi est mort.
signal enemy_died(enemy_name: String, position: Vector2)

## Un ennemi a détecté un joueur.
signal enemy_alerted(enemy_name: String)


# ============================================================
#  MUTATIONS / PROGRESSION
# ============================================================

## Le choix de mutation est disponible (entre deux salles).
signal mutation_choice_available(options: Array[Dictionary])

## Une mutation a été sélectionnée par un joueur.
signal mutation_selected(peer_id: int, mutation_id: String)

## Un DataFragment a été collecté (ressource principale).
signal data_fragment_collected(peer_id: int, amount: int)

## Le score de corruption global a changé.
signal corruption_score_changed(new_score: int)


# ============================================================
#  UI / HUD
# ============================================================

## Affiche un message flottant à l'écran (feedback joueur).
signal floating_text_requested(text: String, position: Vector2, color: Color)

## Demande l'affichage de l'écran de mort.
signal death_screen_requested()

## Demande le retour au menu principal.
signal return_to_main_menu_requested()
