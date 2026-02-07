# 📝 TODO - Améliorations Futures

## ⚠️ Fichiers Non Refactorisés

### Mutations Individuelles (36 fichiers)

La plupart des mutations dans `Scripts/MutationsAvailable/` n'ont pas été refactorisées individuellement. Seules les plus problématiques ont été corrigées:

✅ **Refactorisé:**
- `InvisibleMutation.gd` - Noms de variables améliorés

❌ **Non vérifiés:**
- Les 35 autres mutations

**Action recommandée:** Appliquez le même pattern que `InvisibleMutation.gd` si vous modifiez ces fichiers.

### Pattern à Suivre pour les Mutations

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
    pass

func remove(virus: Node2D) -> void:
    """Called when mutation is removed"""
    pass

# ========================
# UPDATE
# ========================
func process(virus: Node2D, delta: float) -> void:
    """Called every frame if mutation has process method"""
    pass

func apply(virus: Node2D) -> void:
    """Called when mutation key is pressed"""
    pass

# ========================
# COOLDOWN INFO
# ========================
func get_cooldown() -> float:
    return remaining_time if is_on_cooldown else 0.0

func get_max_cooldown() -> float:
    return max_cooldown
```

---

## 🔄 Migrations à Vérifier

### Scènes à Mettre à Jour

Les **scènes** peuvent contenir des références aux anciens noms de propriétés:

1. **Scenes/Virus/Virus.tscn**
   - Vérifiez que les animations/scripts visuels n'utilisent pas `actual_level`
   - Vérifiez que les scripts n'utilisent pas `invisible` directement

2. **Scenes/Enemies/Antivirus.tscn**
   - Vérifiez les connexions de signaux
   - Assurez-vous que `DetectionArea` est bien configuré

3. **Scenes/UI/HUD.tscn**
   - Vérifiez que les références aux nœuds correspondent

4. **Scenes/UI/MutationUI.tscn**
   - Vérifiez la structure des boutons

---

## ✨ Améliorations Recommandées

### Priorité Haute

#### 1. Système de Configuration
```gdscript
# Scripts/Core/Config.gd
extends Node

const GAME_VERSION := "0.1.0"
const DEBUG_MODE := true

const DIFFICULTY := {
    "easy": {...},
    "normal": {...},
    "hard": {...}
}
```

#### 3. Audio Manager
```gdscript
# Scripts/Core/AudioManager.gd
extends Node

func play_sfx(sound_name: String) -> void
func play_music(track_name: String) -> void
func stop_music() -> void
```

### Priorité Moyenne

#### 4. Object Pooling
```gdscript
# Scripts/Core/ObjectPool.gd
class_name ObjectPool

var pool: Array[Node] = []
var scene: PackedScene

func get_object() -> Node
func return_object(obj: Node) -> void
```

**Usage:**
- Pool pour ScanZone (créés/détruits fréquemment)
- Pool pour particules d'infection
- Pool pour effets visuels

#### 5. Data Manager
```gdscript
# Scripts/Core/DataManager.gd
extends Node

func save_game(slot: int) -> bool
func load_game(slot: int) -> bool
func get_high_scores() -> Array
func save_settings(settings: Dictionary) -> void
```

#### 6. Transitions de Scène
```gdscript
# Scripts/Core/SceneTransition.gd
extends CanvasLayer

func fade_to_black(duration: float) -> void
func fade_from_black(duration: float) -> void
func change_scene(path: String) -> void
```

### Priorité Basse

#### 7. Debug Console
```gdscript
# Scripts/Debug/DebugConsole.gd
extends Control

func execute_command(command: String) -> void
func log_message(message: String, type: String) -> void
```

**Commandes utiles:**
- `spawn_antivirus`
- `set_level X`
- `unlock_all_mutations`
- `god_mode`

#### 8. Analytics/Telemetry (optionnel)
```gdscript
# Scripts/Core/Analytics.gd
extends Node

func track_event(event_name: String, data: Dictionary) -> void
func track_level_completion(level: int, time: float) -> void
```

---

## 🎨 Améliorations de Code Spécifiques

### Virus.gd

```gdscript
# TODO: Ajouter système de damage
signal health_changed(new_health: int)
var max_health := 100
var current_health := 100

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health)
    if current_health <= 0:
        _on_death()
```

### Antivirus.gd

```gdscript
# TODO: Ajouter comportements avancés
enum Behavior { PATROL, GUARD, HUNT }
@export var behavior := Behavior.PATROL

# TODO: Ajouter vision cone pour détection
func _draw_vision_cone() -> void
```

### GameManager.gd

```gdscript
# TODO: Ajouter gestion de niveaux
var current_zone := "files"
var zones_completed: Array[String] = []

func complete_zone(zone_name: String) -> void
func unlock_next_zone() -> void
```

---

## 🐛 Bugs Potentiels à Surveiller

### 1. Timers Non Nettoyés
**Fichier:** `Infectable.gd`
**Problème:** Si un Infectable est détruit pendant qu'il a un Timer actif, le Timer pourrait ne pas être libéré.
**Solution actuelle:** Timer est ajouté comme enfant et devrait être auto-nettoyé.

### 2. Signaux Non Déconnectés
**Fichiers:** Plusieurs
**Problème:** Certains signaux connectés manuellement pourraient ne pas être déconnectés.
**Solution:** Vérifier `_exit_tree()` dans tous les scripts qui connectent des signaux.

### 3. Références Invalides Après queue_free()
**Fichier:** `Antivirus.gd`, `ScanZone.gd`
**Problème:** Références à `chase_target` ou autres nodes qui peuvent être détruits.
**Solution actuelle:** Utilisation de `is_instance_valid()`.

---

## 📊 Métriques de Code

### Avant Refactorisation
- Chemins hardcodés: ~10
- Détections par nom: ~8
- États en string: 3
- Code dupliqué: Moyen
- Documentation: Faible

### Après Refactorisation
- Chemins hardcodés: 0 ✅
- Détections par nom: 0 ✅
- États en string: 0 ✅
- Code dupliqué: Faible ✅
- Documentation: Élevée ✅

---

## 🎯 Objectifs Futurs

### Court Terme (1-2 semaines)
- [ ] Tester toutes les mutations
- [ ] Ajouter sons/musique
- [ ] Ajouter effets visuels (particules)
- [ ] Créer menu d'options

### Moyen Terme (1-2 mois)
- [ ] Système de sauvegarde
- [ ] Système de zones (style Dead Cells)
- [ ] Boss fights
- [ ] Plus de types d'antivirus

### Long Terme (3-6 mois)
- [ ] Mode multijoueur local
- [ ] Éditeur de niveaux
- [ ] Mod support
- [ ] Steam integration

---

## 📚 Ressources Utiles

### Godot Documentation
- [Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/)
- [Performance](https://docs.godotengine.org/en/stable/tutorials/performance/)
- [Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html)

### Patterns de Design
- [Game Programming Patterns](https://gameprogrammingpatterns.com/)
- [Godot Recipes](https://kidscancode.org/godot_recipes/4.x/)

### Communauté
- [Godot Discord](https://discord.gg/godotengine)
- [Reddit r/godot](https://www.reddit.com/r/godot/)

---

**Dernière mise à jour:** 2026-02-06  
**Prochaine révision:** À chaque milestone majeur
