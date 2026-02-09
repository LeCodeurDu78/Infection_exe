# 📝 TODO - Améliorations Futures

## ⭐ Priorité HAUTE

### 4. Système de Progression / Achievements

**Pourquoi:** Donne des objectifs à long terme

```gdscript
# Scripts/Core/AchievementManager.gd
extends Node

var achievements := {
	"first_infection": {
		"name": "Premier Virus",
		"description": "Infecter votre premier fichier",
		"unlocked": false,
		"icon": "res://Assets/Icons/achievement_first.png"
	},
	"speed_demon": {
		"name": "Démon de Vitesse",
		"description": "Atteindre le niveau 5 en moins de 2 minutes",
		"unlocked": false,
		"icon": "res://Assets/Icons/achievement_speed.png"
	},
	"mutation_master": {
		"name": "Maître des Mutations",
		"description": "Débloquer 10 mutations",
		"unlocked": false,
		"icon": "res://Assets/Icons/achievement_mutations.png"
	},
	"ghost": {
		"name": "Fantôme",
		"description": "Compléter un niveau sans être détecté",
		"unlocked": false,
		"icon": "res://Assets/Icons/achievement_ghost.png"
	},
	"100_percent": {
		"name": "Infection Totale",
		"description": "Infecter 100% d'un système",
		"unlocked": false,
		"icon": "res://Assets/Icons/achievement_100.png"
	}
}

func _ready():
	_load_achievements()
	_connect_events()

func _connect_events():
	EventBus.infection_completed.connect(_check_first_infection)
	EventBus.virus_leveled_up.connect(_check_speed_demon)
	EventBus.mutation_activated.connect(_check_mutation_master)
	EventBus.game_won.connect(_check_100_percent)

func unlock_achievement(id: String):
	if achievements[id].unlocked:
		return
	
	achievements[id].unlocked = true
	EventBus.emit_notification("🏆 Achievement: " + achievements[id].name, "success")
	_save_achievements()

func _save_achievements():
	SaveManager.data["achievements"] = achievements
	SaveManager.save_data()

func _load_achievements():
	if "achievements" in SaveManager.data:
		achievements = SaveManager.data.achievements
```

**Achievements à implémenter:**
- 🦠 Premier virus (infecter 1 fichier)
- ⚡ Démon de vitesse (niveau 5 en < 2min)
- 🧬 Maître des mutations (10 mutations débloquées)
- 👻 Fantôme (0 détection en 1 partie)
- 💯 Infection totale (100% infecté)
- 🎯 Sniper (infecter 50 fichiers sans rater)
- 🛡️ Tank (subir 100 dégâts sans mourir)
- 🔥 Pyromane (utiliser une mutation explosive 50 fois)
- ⏱️ Speedrun (finir en moins de 5 minutes)
- 🎮 Perfectionniste (débloquer tous les achievements)

---

### 5. Système de Zones / Niveaux (Dead Cells style)

**Pourquoi:** C'est dans le GDD original, ajoute de la rejouabilité

```gdscript
# Scripts/Core/ZoneManager.gd
extends Node

enum ZoneType { FILES, PROCESSES, NETWORK, ADMIN, CORE }

var zones := {
	ZoneType.FILES: {
		"name": "Zone Fichiers",
		"difficulty": 1,
		"unlocked": true,
		"scene": "res://Scenes/Zones/FilesZone.tscn",
		"next_zones": [ZoneType.PROCESSES, ZoneType.NETWORK],
		"description": "Zone de départ. Fichiers basiques, peu de défense."
	},
	ZoneType.PROCESSES: {
		"name": "Zone Processus",
		"difficulty": 2,
		"unlocked": false,
		"scene": "res://Scenes/Zones/ProcessesZone.tscn",
		"next_zones": [ZoneType.NETWORK, ZoneType.ADMIN],
		"description": "Processus actifs. Éléments mobiles, scans fréquents."
	},
	ZoneType.NETWORK: {
		"name": "Zone Réseau",
		"difficulty": 3,
		"unlocked": false,
		"scene": "res://Scenes/Zones/NetworkZone.tscn",
		"next_zones": [ZoneType.ADMIN],
		"description": "Infrastructure réseau. Firewalls, propagation en chaîne."
	},
	ZoneType.ADMIN: {
		"name": "Zone Admin",
		"difficulty": 4,
		"unlocked": false,
		"scene": "res://Scenes/Zones/AdminZone.tscn",
		"next_zones": [ZoneType.CORE],
		"description": "Zone administrative. Meilleures mutations, surveillance maximale."
	},
	ZoneType.CORE: {
		"name": "Noyau",
		"difficulty": 5,
		"unlocked": false,
		"scene": "res://Scenes/Zones/CoreZone.tscn",
		"next_zones": [],
		"description": "Zone finale. Boss fight. Victoire ou défaite."
	}
}

var current_zone: ZoneType = ZoneType.FILES
var zones_completed: Array[ZoneType] = []

func complete_zone(zone: ZoneType):
	if zone not in zones_completed:
		zones_completed.append(zone)
	
	# Unlock next zones
	for next_zone in zones[zone].next_zones:
		zones[next_zone].unlocked = true
	
	EventBus.zone_completed.emit(zones[zone].name, 100.0)

func load_zone(zone: ZoneType):
	if not zones[zone].unlocked:
		return
	
	current_zone = zone
	get_tree().change_scene_to_file(zones[zone].scene)
	EventBus.zone_entered.emit(zones[zone].name)

func show_zone_selection():
	# Afficher un écran de sélection avec les zones débloquées
	# Style Dead Cells avec chemins visibles
	pass
```

**Spécificités par zone:**
- **Files:** Infectables statiques, antivirus lents
- **Processes:** Infectables mobiles, scans toutes les 10s
- **Network:** Firewalls, infection en chaîne
- **Admin:** Mutations premium, antivirus rapides
- **Core:** Boss fight, objectif final

---

### 6. Boss Fight System

**Pourquoi:** Zone Core nécessite un boss final épique

```gdscript
# Scripts/Enemies/Boss.gd
extends CharacterBody2D

enum Phase { ONE, TWO, THREE }

@export var max_health := 1000
var current_health := 1000
var current_phase := Phase.ONE

# Phase 1: Slow but tanky
# Phase 2: Faster, spawns mini-antivirus
# Phase 3: Berserk, screen-wide scans

func _ready():
	EventBus.emit_notification("⚠️ BOSS FIGHT: Firewall Principal", "error")
	EventBus.emit_music("boss", 2.0)
	EventBus.emit_screen_shake(2.0, 1.0)

func take_damage(amount: int):
	current_health -= amount
	EventBus.emit_screen_shake(0.5, 0.1)
	
	# Phase transitions
	if current_health <= 666 and current_phase == Phase.ONE:
		_enter_phase_two()
	elif current_health <= 333 and current_phase == Phase.TWO:
		_enter_phase_three()
	
	if current_health <= 0:
		_on_defeated()

func _enter_phase_two():
	current_phase = Phase.TWO
	EventBus.emit_notification("⚠️ PHASE 2: Le boss devient enragé!", "warning")
	EventBus.emit_screen_shake(1.5, 0.5)
	# Spawn minions
	# Increase attack speed

func _enter_phase_three():
	current_phase = Phase.THREE
	EventBus.emit_notification("⚠️ PHASE 3: BERSERK MODE!", "error")
	EventBus.emit_screen_shake(2.0, 1.0)
	# Screen-wide attacks
	# Maximum difficulty

func _on_defeated():
	EventBus.emit_notification("✅ VICTOIRE! Système infecté!", "success")
	EventBus.game_won.emit(100.0, GameManager.get_elapsed_time())
	queue_free()
```

**Patterns d'attaque par phase:**

**Phase 1 (100%-66%):**
- Scans localisés toutes les 5s
- Déplacement lent
- Spawne des murs de firewall

**Phase 2 (66%-33%):**
- Scans toutes les 3s
- Spawne 2 mini-antivirus toutes les 10s
- Déplacement rapide

**Phase 3 (33%-0%):**
- Scans en vagues (toute la zone)
- Spawne 4 mini-antivirus toutes les 5s
- Téléportations
- Zone entière devient dangereuse

---

### 7. Power-Ups Temporaires

**Pourquoi:** Ajoute du chaos et des choix tactiques

```gdscript
# Scripts/Environment/PowerUp.gd
extends Area2D

enum PowerUpType {
	SPEED_BOOST,      # +50% vitesse pendant 10s
	SHIELD,           # Immunité pendant 5s
	XP_MULTIPLIER,    # x2 XP pendant 15s
	INFECTION_BURST,  # Infecte tout dans un rayon
	TIME_SLOW,        # Ralentit les antivirus pendant 8s
	GHOST_MODE,       # Invisibilité temporaire
	MUTATION_RESET    # Reset cooldowns
}

@export var power_up_type: PowerUpType
@export var duration := 10.0

var icon_textures := {
	PowerUpType.SPEED_BOOST: preload("res://Assets/Icons/powerup_speed.png"),
	PowerUpType.SHIELD: preload("res://Assets/Icons/powerup_shield.png"),
	# etc...
}

func _ready():
	$Sprite.texture = icon_textures[power_up_type]
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if area.is_in_group("virus_infection_zone"):
		_apply_power_up()
		EventBus.emit_sfx("powerup_collected")
		queue_free()

func _apply_power_up():
	var virus = GameManager.virus_node
	match power_up_type:
		PowerUpType.SPEED_BOOST:
			virus.base_speed *= 1.5
			await get_tree().create_timer(duration).timeout
			virus.base_speed /= 1.5
		
		PowerUpType.SHIELD:
			virus.invulnerable = true
			await get_tree().create_timer(duration).timeout
			virus.invulnerable = false
		
		PowerUpType.XP_MULTIPLIER:
			virus.xp_multiplier = 2.0
			await get_tree().create_timer(duration).timeout
			virus.xp_multiplier = 1.0
		
		PowerUpType.INFECTION_BURST:
			# Infecte tout dans un rayon de 200px
			var infectables = get_tree().get_nodes_in_group("infectables")
			for infectable in infectables:
				if virus.global_position.distance_to(infectable.global_position) < 200:
					infectable.instant_infect()
		
		PowerUpType.TIME_SLOW:
			Engine.time_scale = 0.5
			await get_tree().create_timer(duration).timeout
			Engine.time_scale = 1.0
```

**Spawn logic:**
- Apparaissent aléatoirement dans la zone
- Plus rares dans les zones faciles
- Plus fréquents dans les zones difficiles
- Disparaissent après 20s si non collectés

---

## ⭐ Priorité MOYENNE

### 8. Système de Scoring / Leaderboard

```gdscript
# Scripts/Core/ScoreManager.gd
extends Node

var current_score := 0
var multiplier := 1.0
var combo := 0

func _ready():
	EventBus.infection_completed.connect(_on_infection_scored)
	EventBus.virus_leveled_up.connect(_on_level_up_scored)

func _on_infection_scored(target: Node2D, points: int):
	combo += 1
	multiplier = 1.0 + (combo * 0.1) # +10% par combo
	var score = int(points * multiplier)
	current_score += score
	
	EventBus.emit_notification("+%d (x%.1f)" % [score, multiplier], "success")
	
	# Reset combo si pas d'infection pendant 5s
	await get_tree().create_timer(5.0).timeout
	combo = 0
	multiplier = 1.0

func _on_level_up_scored(new_level: int):
	var bonus = new_level * 100
	current_score += bonus

func save_highscore():
	if "highscores" not in SaveManager.data:
		SaveManager.data.highscores = []
	
	SaveManager.data.highscores.append({
		"score": current_score,
		"date": Time.get_datetime_string_from_system(),
		"zone": GameManager.current_zone
	})
	
	# Keep top 10
	SaveManager.data.highscores.sort_custom(func(a, b): return a.score > b.score)
	SaveManager.data.highscores = SaveManager.data.highscores.slice(0, 10)
	
	SaveManager.save_data()
```

**Écran de Leaderboard:**
- Top 10 scores
- Date et zone
- Stats détaillées (temps, infections, mutations utilisées)
- Option de partage (screenshot)

---

### 9. Système de Tutoriel Interactif

**Pourquoi:** Le jeu a beaucoup de mécaniques à apprendre

```gdscript
# Scripts/UI/TutorialManager.gd
extends CanvasLayer

var tutorials := {
	"movement": {
		"title": "Déplacement",
		"text": "Utilisez ZQSD ou les flèches pour vous déplacer",
		"trigger": "game_started",
		"shown": false
	},
	"infection": {
		"title": "Infection",
		"text": "Restez proche d'un fichier pour l'infecter",
		"trigger": "first_infectable_detected",
		"shown": false
	},
	"mutations": {
		"title": "Mutations",
		"text": "Gagnez de l'XP pour débloquer des mutations puissantes",
		"trigger": "first_level_up",
		"shown": false
	},
	"antivirus": {
		"title": "Antivirus",
		"text": "Attention! Les antivirus chassent et détruisent le virus",
		"trigger": "first_antivirus_spawned",
		"shown": false
	}
}

func _ready():
	_connect_triggers()

func _connect_triggers():
	EventBus.game_started.connect(func(): show_tutorial("movement"))
	EventBus.infection_started.connect(func(t, p): show_tutorial("infection"))
	EventBus.virus_leveled_up.connect(func(l): show_tutorial("mutations"))
	EventBus.antivirus_spawned.connect(func(a, p): show_tutorial("antivirus"))

func show_tutorial(id: String):
	if tutorials[id].shown:
		return
	
	tutorials[id].shown = true
	$TutorialPanel.show_message(
		tutorials[id].title,
		tutorials[id].text
	)
	
	# Pause game
	get_tree().paused = true
	await $TutorialPanel.confirmed
	get_tree().paused = false
```

**Tutoriels à créer:**
1. Déplacement (ZQSD)
2. Infection (rester proche)
3. Mutations (XP → mutations)
4. Antivirus (danger rouge)
5. Scans (zones orange)
6. Power-ups (bonus temporaires)
7. Zones (progression)

---

## 🎨 Priorité BASSE (Polish)

### 11. Cinématiques

**Intro:**
- Logo Glitch (déjà l'addon glitch_intro)
- Cutscene: "Virus détecté... Initiating quarantine..."
- Zoom sur le virus qui prend vie

**Outro (Victoire):**
- Animation du système qui se corrompt
- Écran qui glitch complètement
- "SYSTEM INFECTED - 100%"
- Crédits

**Outro (Défaite):**
- Virus détruit en particules
- "THREAT ELIMINATED"
- Stats de la partie

---

### 12. Mini-Map

```gdscript
# Scripts/UI/MiniMap.gd
extends Control

@export var zoom := 0.1
var markers := {}

func _ready():
	EventBus.antivirus_spawned.connect(_add_antivirus_marker)
	EventBus.antivirus_despawned.connect(_remove_antivirus_marker)

func _process(delta):
	queue_redraw()

func _draw():
	# Draw zone boundaries
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK, false, 2.0)
	
	# Draw virus position
	if GameManager.virus_node:
		var pos = _world_to_minimap(GameManager.virus_node.global_position)
		draw_circle(pos, 3.0, Color.GREEN)
	
	# Draw antivirus
	for av in markers.values():
		var pos = _world_to_minimap(av.global_position)
		draw_circle(pos, 2.0, Color.RED)

func _world_to_minimap(world_pos: Vector2) -> Vector2:
	# Convert world coordinates to minimap coordinates
	return world_pos * zoom
```

---

### 13. Skins pour le Virus

```gdscript
# Scripts/UI/SkinSelector.gd
extends Control

var skins := {
	"default": {
		"name": "Virus Classique",
		"sprite": preload("res://Assets/Sprites/Virus/default.png"),
		"unlocked": true
	},
	"neon": {
		"name": "Néon",
		"sprite": preload("res://Assets/Sprites/Virus/neon.png"),
		"unlocked": false,
		"unlock_condition": "Atteindre le niveau 10"
	},
	"ghost": {
		"name": "Fantôme",
		"sprite": preload("res://Assets/Sprites/Virus/ghost.png"),
		"unlocked": false,
		"unlock_condition": "Compléter une partie sans être détecté"
	}
}
```

---

### 14. Système de Difficulté

```gdscript
# Dans GameManager.gd

enum Difficulty { EASY, NORMAL, HARD, NIGHTMARE }

var current_difficulty := Difficulty.NORMAL

var difficulty_modifiers := {
	Difficulty.EASY: {
		"antivirus_speed": 0.7,
		"scan_frequency": 1.5,
		"damage_multiplier": 0.5,
		"xp_multiplier": 1.5
	},
	Difficulty.NORMAL: {
		"antivirus_speed": 1.0,
		"scan_frequency": 1.0,
		"damage_multiplier": 1.0,
		"xp_multiplier": 1.0
	},
	Difficulty.HARD: {
		"antivirus_speed": 1.3,
		"scan_frequency": 0.7,
		"damage_multiplier": 1.5,
		"xp_multiplier": 0.8
	},
	Difficulty.NIGHTMARE: {
		"antivirus_speed": 1.8,
		"scan_frequency": 0.5,
		"damage_multiplier": 2.0,
		"xp_multiplier": 0.5
	}
}
```

---

### 15. Système de Stats en Fin de Partie

```gdscript
# Scripts/UI/EndGameStats.gd
extends Control

func show_stats():
	var stats = {
		"Temps écoulé": GameManager.get_elapsed_time(),
		"Fichiers infectés": GameManager.infected_count,
		"Level atteint": GameManager.virus_node.current_level,
		"Mutations utilisées": _count_used_mutations(),
		"Dégâts subis": GameManager.virus_node.total_damage_taken,
		"Scans évités": GameManager.scans_dodged,
		"Score": ScoreManager.current_score,
		"Rang": _calculate_rank()
	}
	
	_display_stats(stats)

func _calculate_rank() -> String:
	var score = ScoreManager.current_score
	if score > 10000: return "S"
	if score > 7500: return "A"
	if score > 5000: return "B"
	if score > 2500: return "C"
	return "D"
```

---

## 🛠️ Améliorations Techniques

### 16. Object Pooling pour les Particules et Scans

```gdscript
# Scripts/Core/ObjectPool.gd
class_name ObjectPool

var pool: Array[Node] = []
var scene: PackedScene
var pool_size := 20
var parent: Node

func _init(_scene: PackedScene, _parent: Node, _size: int = 20):
	scene = _scene
	parent = _parent
	pool_size = _size
	_populate_pool()

func _populate_pool():
	for i in pool_size:
		var obj = scene.instantiate()
		obj.visible = false
		parent.add_child(obj)
		pool.append(obj)

func get_object() -> Node:
	for obj in pool:
		if not obj.visible:
			obj.visible = true
			return obj
	
	# Pool exhausted, create new object
	var obj = scene.instantiate()
	parent.add_child(obj)
	pool.append(obj)
	return obj

func return_object(obj: Node):
	obj.visible = false
	obj.global_position = Vector2(-10000, -10000) # Move off-screen
```

**Utilisation:**
```gdscript
# Dans ScanZone spawner
var scan_pool: ObjectPool

func _ready():
	scan_pool = ObjectPool.new(
		preload("res://Scenes/Enemies/ScanZone.tscn"),
		get_tree().current_scene,
		10
	)

func spawn_scan():
	var scan = scan_pool.get_object()
	scan.global_position = target_position
	scan.activate()
	
	await scan.finished
	scan_pool.return_object(scan)
```

---

### 17. Amélioration du SaveManager

**Ajouter support pour:**
```gdscript
# Dans SaveManager.gd

@export var data = {
	"options": { ... }, # Existing
	
	"game_progress": {
		"zones_unlocked": [],
		"zones_completed": [],
		"current_zone": "files",
		"mutations_unlocked": [],
		"total_playtime": 0.0,
	},
	
	"achievements": {},
	
	"highscores": [],
	
	"statistics": {
		"total_infections": 0,
		"total_deaths": 0,
		"total_scans_dodged": 0,
		"total_mutations_used": 0,
		"fastest_completion": 999999.0
	}
}

# Auto-save game progress
func auto_save_progress():
	data.game_progress = {
		"zones_unlocked": ZoneManager.get_unlocked_zones(),
		"zones_completed": ZoneManager.zones_completed,
		"current_zone": ZoneManager.current_zone,
		"mutations_unlocked": MutationManager.get_unlocked_mutations(),
		"total_playtime": data.game_progress.total_playtime + GameManager.get_elapsed_time()
	}
	save_data()
```

---

### 18. Debug Console

```gdscript
# Scripts/Debug/DebugConsole.gd
extends Control

var commands := {
	"god": "Toggle god mode",
	"speed [value]": "Set virus speed",
	"level [value]": "Set virus level",
	"spawn_av [count]": "Spawn antivirus",
	"unlock_all": "Unlock all mutations",
	"clear_save": "Clear save data",
	"set_zone [name]": "Change zone",
	"add_xp [amount]": "Add XP",
	"kill_all_av": "Destroy all antivirus"
}

func _ready():
	visible = false

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		visible = not visible

func execute_command(command: String):
	var parts = command.split(" ")
	var cmd = parts[0]
	
	match cmd:
		"god":
			GameManager.virus_node.god_mode = not GameManager.virus_node.god_mode
			log("God mode: " + str(GameManager.virus_node.god_mode))
		
		"speed":
			if parts.size() > 1:
				GameManager.virus_node.base_speed = float(parts[1])
				log("Speed set to: " + parts[1])
		
		"level":
			if parts.size() > 1:
				GameManager.virus_node.current_level = int(parts[1])
				log("Level set to: " + parts[1])
		
		"unlock_all":
			for mutation in MutationManager.available_mutations:
				MutationManager.activate_mutation(mutation)
			log("All mutations unlocked")
		
		_:
			log("Unknown command: " + cmd)

func log(message: String):
	$Output.text += "\n> " + message
```

**Activation:**
- F1 pour ouvrir/fermer
- Autocomplete des commandes
- Historique des commandes (↑↓)

---

## 📊 Métriques et Analytics

### 19. Système de Tracking

```gdscript
# Scripts/Core/Analytics.gd
extends Node

var session_data := {
	"session_start": 0.0,
	"events": []
}

func _ready():
	session_data.session_start = Time.get_ticks_msec() / 1000.0
	_connect_all_events()

func _connect_all_events():
	EventBus.infection_completed.connect(_track_infection)
	EventBus.virus_leveled_up.connect(_track_level_up)
	EventBus.mutation_activated.connect(_track_mutation_activated)
	EventBus.game_won.connect(_track_victory)
	EventBus.game_lost.connect(_track_defeat)

func track_event(event_name: String, data: Dictionary = {}):
	session_data.events.append({
		"name": event_name,
		"timestamp": Time.get_ticks_msec() / 1000.0 - session_data.session_start,
		"data": data
	})

func _track_infection(target: Node2D, points: int):
	track_event("infection", {"points": points})

func save_session():
	# Could export to JSON for analysis
	var file = FileAccess.open("user://analytics_%s.json" % Time.get_datetime_string_from_system(), FileAccess.WRITE)
	file.store_string(JSON.stringify(session_data, "\t"))
	file.close()
```

---

## 🎯 Objectifs Mis à Jour

### Court Terme (1-2 semaines)
- [x] **ParticleManager** (CRITIQUE)
- [x] **ScreenShakeManager** (CRITIQUE)
- [ ] **NotificationManager** (CRITIQUE)
- [ ] AchievementManager
- [x] Améliorer effets visuels

### Moyen Terme (1-2 mois)
- [ ] Système de zones / levels
- [ ] Boss fight (Core zone)
- [ ] Power-ups temporaires
- [ ] Scoring / Leaderboard
- [ ] Tutoriel interactif
- [ ] Plus de types d'antivirus

### Long Terme (3-6 mois)
- [ ] Cinématiques intro/outro
- [ ] Mini-map
- [ ] Skins pour le virus
- [ ] Système de difficulté
- [ ] Tester toutes les mutations
- [ ] Stats détaillées
- [ ] Mode multijoueur local
- [ ] Éditeur de niveaux
- [ ] Steam integration

---

## 🚀 Quick Wins (Facile et Impactant)

2. **NotificationManager** - 1-2h, feedback immédiat
---

## 🎨 Pattern à Suivre pour les Mutations

[Conservé du TODO original]

```gdscript
extends Mutation

## Brief description of what this mutation does

# ========================
# EXPORTS
# ========================
@export var param_name := 1.0

# ========================
# STATE
# ========================
var is_active := false
var remaining_time := 0.0

# ========================
# LIFECYCLE
# ========================
func ready(virus: Node2D) -> void:
	"""Called when mutation is activated"""
	EventBus.mutation_activated.emit(self)

func remove(virus: Node2D) -> void:
	"""Called when mutation is removed"""
	EventBus.mutation_deactivated.emit(self)

# ========================
# UPDATE
# ========================
func process(virus: Node2D, delta: float) -> void:
	"""Called every frame if mutation has process method"""
	pass

func apply(virus: Node2D) -> void:
	"""Called when mutation key is pressed"""
	EventBus.mutation_ability_used.emit(name)

# ========================
# COOLDOWN INFO
# ========================
func get_cooldown() -> float:
	return remaining_time if is_on_cooldown else 0.0

func get_max_cooldown() -> float:
	return max_cooldown
```

---

**Dernière mise à jour:** 2026-02-08  
**Version:** 2.0.0 (Enrichi avec nouvelles suggestions)
