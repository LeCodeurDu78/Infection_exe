# 🗺️🏆 ZoneManager & AchievementManager - Guide d'Installation

## 📦 Fichiers Créés

### ZoneManager (Système de Zones)
- `Scripts/Core/ZoneManager.gd` - Gestionnaire (Autoload)
- `Scripts/UI/ZoneSelector.gd` - Sélecteur de zones
- `Scripts/UI/ZoneButton.gd` - Bouton de zone
- `Scenes/UI/ZoneSelector.tscn` - Scène du sélecteur
- `Scenes/UI/ZoneButton.tscn` - Scène du bouton

### AchievementManager (Système d'Achievements)
- `Scripts/Core/AchievementManager.gd` - Gestionnaire (Autoload)
- `Scripts/UI/AchievementPanel.gd` - Panneau d'achievements
- `Scripts/UI/AchievementItem.gd` - Item d'achievement
- `Scenes/UI/AchievementPanel.tscn` - Scène du panneau
- `Scenes/UI/AchievementItem.tscn` - Scène de l'item

### EventBus (Additions)
- `EventBus_additions.gd` - Signaux à ajouter

**Total: 11 fichiers**

---

## 🚀 Installation (20 minutes)

### Partie 1: EventBus - Ajouter les Signaux (2 min)

Ouvrez votre `Scripts/Core/EventBus.gd` et ajoutez ces signaux:

```gdscript
# ===== ZONE SIGNALS =====
signal zone_entered(zone_name: String)
signal zone_completed(zone_name: String, infection_percent: float)
signal zone_unlocked(zone_name: String)

# ===== ACHIEVEMENT SIGNALS =====
signal achievement_unlocked(achievement_name: String)
signal achievement_progress(achievement_name: String, progress: int, target: int)
```

---

### Partie 2: ZoneManager (8 min)

#### Étape 1: Copier les Fichiers
```
Scripts/Core/ZoneManager.gd
Scripts/UI/ZoneSelector.gd
Scripts/UI/ZoneButton.gd
Scenes/UI/ZoneSelector.tscn
Scenes/UI/ZoneButton.tscn
```

#### Étape 2: Ajouter comme Autoload
1. **Project Settings** → **Autoload**
2. Path: `res://Scripts/Core/ZoneManager.gd`
3. Name: `ZoneManager`
4. Cliquez **Add**

**Ordre recommandé:**
```
1. GameManager
2. EventBus
3. AudioManager
4. ParticleManager
5. NotificationManager
6. ZoneManager          ← ICI
7. AchievementManager   (on va l'ajouter après)
```

#### Étape 3: Créer les Scènes de Zones

Pour l'instant, créez des scènes basiques (vous les remplirez plus tard):

**Créer dans Scenes/Zones/:**
1. `FilesZone.tscn` - Zone de départ
2. `ProcessesZone.tscn` - Zone 2
3. `NetworkZone.tscn` - Zone 3
4. `AdminZone.tscn` - Zone 4
5. `CoreZone.tscn` - Zone finale (boss)

**Contenu minimal de chaque scène:**
- Node2D racine
- Un TileMap ou Node2D avec quelques éléments
- Script qui appelle `ZoneManager.complete_zone()` quand terminée

---

### Partie 3: AchievementManager (10 min)

#### Étape 1: Copier les Fichiers
```
Scripts/Core/AchievementManager.gd
Scripts/UI/AchievementPanel.gd
Scripts/UI/AchievementItem.gd
Scenes/UI/AchievementPanel.tscn
Scenes/UI/AchievementItem.tscn
```

#### Étape 2: Ajouter comme Autoload
1. **Project Settings** → **Autoload**
2. Path: `res://Scripts/Core/AchievementManager.gd`
3. Name: `AchievementManager`
4. Cliquez **Add**

#### Étape 3: Ajouter le Panneau à Votre UI

Dans votre scène principale ou menu:
1. Instancier `Scenes/UI/AchievementPanel.tscn`
2. Ajouter un bouton "Achievements" qui appelle:
```gdscript
$AchievementPanel.show_panel()
```

---

## 🎯 Utilisation

### ZoneManager

#### Démarrer une Zone
```gdscript
# Dans votre menu principal
func _on_start_button_pressed():
    ZoneManager.start_zone("files")  # Démarre la zone fichiers
```

#### Compléter une Zone
```gdscript
# Dans votre scène de zone (quand objectif atteint)
func _on_zone_objective_complete():
    var infection_percent = get_infection_percent()
    ZoneManager.complete_zone("files", infection_percent)
```

#### Afficher le Sélecteur de Zones
```gdscript
# Dans votre menu/UI
func _on_select_zone_button_pressed():
    var zone_selector = load("res://Scenes/UI/ZoneSelector.tscn").instantiate()
    add_child(zone_selector)
    zone_selector.show_selector()
```

---

### AchievementManager

#### Débloquer un Achievement
```gdscript
# Déblocage simple
AchievementManager.unlock_achievement("first_infection")
```

#### Ajouter de la Progression
```gdscript
# Pour les achievements avec cible > 1
AchievementManager.add_progress("infect_100")  # +1
AchievementManager.add_progress("infect_500", 5)  # +5
```

---

## 🏆 Liste des Achievements

### Progression (4)
- **Premier Contact** 🦠 - Infecter votre premier fichier
- **Évolution Complète** ⬆️ - Atteindre le niveau 5
- **Explorateur Système** 🗺️ - Compléter toutes les zones
- **Cœur du Système** 💎 - Atteindre le Noyau Système

### Infection (3)
- **Épidémie** 📁 - Infecter 100 fichiers
- **Pandémie** 🌐 - Infecter 500 fichiers
- **Infection Totale** ✨ - Infecter 100% d'une zone

### Combat (3)
- **Antivirus Killer** 🛡️ - Détruire 10 antivirus
- **Furtif** 👻 - Compléter une zone sans dégâts
- **Survivant** ⚠️ - Survivre 60s en menace critique

### Mutations (2)
- **ADN Parfait** 🧬 - Débloquer toutes les mutations
- **Multi-Mutation** 🔀 - Utiliser 5 mutations en un run

### Vitesse (2)
- **Vitesse Éclair** ⚡ - Zone en moins de 2 minutes
- **Marathonien** 🏃 - 1 heure sans mourir

### Secrets (2)
- **???** ❓ - Découvrez le glitch secret
- **???** 💻 - Trouvez le message du développeur

**Total: 16 achievements**

---

**Pour plus de détails, voir INSTALLATION.md complet**
