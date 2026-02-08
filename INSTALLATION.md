# 🎨 ParticleManager - Guide d'Installation

## 📦 Fichiers Créés

### Script Principal
- `Scripts/Core/ParticleManager.gd` - Gestionnaire de particules

### Scènes de Particules (7 effets)
1. `Scenes/Particles/InfectionParticles.tscn` - Particules vertes d'infection
2. `Scenes/Particles/LevelUpParticles.tscn` - Explosion cyan de level up
3. `Scenes/Particles/HitParticles.tscn` - Glitch rouge de dégâts
4. `Scenes/Particles/MutationParticles.tscn` - Spirale magenta de mutation
5. `Scenes/Particles/ScanWaveParticles.tscn` - Onde orange de scan
6. `Scenes/Particles/DashTrailParticles.tscn` - Traînée verte de dash
7. `Scenes/Particles/PropagationParticles.tscn` - Onde verte de propagation

---

## 🚀 Installation (5 minutes)

### Étape 1: Copier les Fichiers

1. **Copier le script:**
   - `Scripts/Core/ParticleManager.gd` → votre projet

2. **Copier les scènes:**
   - Tout le dossier `Scenes/Particles/` → votre projet

### Étape 2: Ajouter ParticleManager comme Autoload

1. Ouvrez **Project Settings** → **Autoload**
2. Cliquez sur l'icône de dossier
3. Sélectionnez `res://Scripts/Core/ParticleManager.gd`
4. Dans **Node Name**, tapez: `ParticleManager`
5. Cliquez **Add**

**⚠️ Important:** Placez ParticleManager APRÈS GameManager et EventBus dans l'ordre !

```
Ordre des Autoloads:
1. GameManager
2. EventBus
3. AudioManager (si vous l'avez)
4. ParticleManager  ← ICI
```

### Étape 3: Vérifier que ça Fonctionne

Lancez le jeu et vérifiez dans la console:
```
🎨 ParticleManager initialized
```

Si vous voyez ce message, c'est bon ! ✅

---

## 🎯 Utilisation

### Automatique (déjà connecté)

Le ParticleManager écoute automatiquement ces événements EventBus:

| Événement | Particules Spawned | Couleur |
|-----------|-------------------|---------|
| `infection_started` | InfectionParticles (petit) | Vert |
| `infection_completed` | InfectionParticles + Propagation | Vert |
| `virus_leveled_up` | LevelUpParticles | Cyan |
| `virus_damaged` | HitParticles | Rouge |
| `mutation_activated` | MutationParticles | Magenta |
| `scan_launched` | ScanWaveParticles | Orange |

**Aucune configuration nécessaire !** Jouez et les particules apparaîtront automatiquement. 🎉

### Manuel (optionnel)

Si vous voulez spawner des particules manuellement:

```gdscript
# N'importe où dans votre code

# Spawner des particules d'infection
ParticleManager.spawn_particle("infection", Vector2(100, 100))

# Spawner avec scale personnalisé
ParticleManager.spawn_particle("level_up", virus_position, 2.0)

# Spawner un trail de dash (dans une boucle)
ParticleManager.spawn_dash_trail(virus.global_position)
```

---

## 🎨 Personnalisation des Particules

### Modifier les Couleurs

Ouvrez une scène `.tscn` dans Godot:

1. Sélectionnez le nœud `GPUParticles2D`
2. Dans **Process Material** → **Color**
3. Changez la couleur comme vous voulez

**Exemples:**
- Infection: `Color(0, 1, 0.4, 1)` - Vert néon
- Level Up: `Color(0.2, 1, 1, 1)` - Cyan
- Hit: `Color(1, 0.2, 0.2, 1)` - Rouge

### Modifier la Quantité de Particules

Dans chaque scène `.tscn`:
- **Amount** : Nombre de particules (16-64)
- **Lifetime** : Durée de vie (0.4-1.5s)
- **Explosiveness** : Intensité de l'explosion (0.0-1.0)

### Modifier la Vitesse

Dans **Process Material** → **Initial Velocity**:
- **Min/Max** : Vitesse de projection (50-200)

### Modifier la Direction

Dans **Process Material**:
- **Direction** : Vector3(0, -1, 0) pour vers le haut
- **Spread** : Angle de dispersion (0-180°)

---

## 🔧 Optimisation

### Pool de Particules (Optionnel)

Si vous spawnez BEAUCOUP de particules (>50/seconde), ajoutez un pool:

```gdscript
# Dans ParticleManager.gd

var particle_pools := {}
const POOL_SIZE := 10

func _ready():
	_create_pools()

func _create_pools():
	for type in particle_scenes:
		particle_pools[type] = []
		for i in POOL_SIZE:
			var particle = particle_scenes[type].instantiate()
			particle.visible = false
			get_tree().current_scene.add_child(particle)
			particle_pools[type].append(particle)

func get_pooled_particle(type: String) -> GPUParticles2D:
	for particle in particle_pools[type]:
		if not particle.emitting:
			return particle
	
	# Pool exhausted, return null (create new or ignore)
	return null
```

### Limiter les Particules Actives

```gdscript
# Dans ParticleManager.gd

const MAX_ACTIVE_PARTICLES := 50

func spawn_particle(...):
	if active_particles.size() >= MAX_ACTIVE_PARTICLES:
		return # Ignore si trop de particules
	
	# ... existing code
```

---

## 🎮 Exemples d'Utilisation Avancée

### 1. Dash Trail Continu

Dans votre script `Virus.gd`:

```gdscript
func _physics_process(delta):
	if is_dashing:
		# Spawn trail toutes les frames
		ParticleManager.spawn_dash_trail(global_position)
	
	# ... existing code
```

### 2. Particules sur Mort d'Ennemi

Dans `Antivirus.gd`:

```gdscript
func _on_destroyed():
	ParticleManager.spawn_particle("virus_hit", global_position, 1.5)
	queue_free()
```

### 3. Particules de Power-Up

```gdscript
# PowerUp.gd
func _on_collected():
	ParticleManager.spawn_particle("mutation_activated", global_position, 1.2)
	EventBus.emit_sfx("powerup_collect")
	queue_free()
```

### 4. Feedback Visuel sur Scan

Les scans spawneront automatiquement une onde orange grâce à EventBus ! 🎯

---

## 🐛 Troubleshooting

### Les particules n'apparaissent pas

**Solution 1:** Vérifiez l'Autoload
- Project Settings → Autoload
- ParticleManager doit être présent et actif

**Solution 2:** Vérifiez les chemins dans ParticleManager.gd
```gdscript
# Les chemins doivent correspondre à votre structure:
"infection": preload("res://Scenes/Particles/InfectionParticles.tscn"),
```

**Solution 3:** Vérifiez la console
- Regardez s'il y a des erreurs de preload
- Vérifiez que les fichiers .tscn existent

### Les particules sont trop grosses/petites

Ajustez le `scale_factor` dans les appels:

```gdscript
# Plus petit
ParticleManager.spawn_particle("infection", pos, 0.5)

# Plus gros
ParticleManager.spawn_particle("level_up", pos, 2.0)
```

### Les particules ne disparaissent pas

C'est normal ! Elles sont automatiquement détruites après:
- `lifetime * 2.0` secondes

Si elles persistent, vérifiez que `one_shot = true` dans les scènes.

### Performance lente

**Solution 1:** Réduire Amount
- Infection: 32 → 16
- Level Up: 64 → 32

**Solution 2:** Utiliser un pool (voir Optimisation ci-dessus)

**Solution 3:** Limiter les particules actives max (voir Optimisation)

---

## 🎨 Palette de Couleurs Cyber

Pour garder une cohérence visuelle:

| Effet | Couleur | Hex | RGB |
|-------|---------|-----|-----|
| Infection | Vert néon | `#00FF66` | `0, 255, 102` |
| Level Up | Cyan | `#33FFFF` | `51, 255, 255` |
| Hit/Damage | Rouge | `#FF3333` | `255, 51, 51` |
| Mutation | Magenta | `#FF00FF` | `255, 0, 255` |
| Scan | Orange | `#FF9933` | `255, 153, 51` |
| Trail | Vert foncé | `#00CC66` | `0, 204, 102` |

---

## 📊 Stats des Particules

| Particule | Amount | Lifetime | Velocité | Explosivité |
|-----------|--------|----------|----------|-------------|
| Infection | 32 | 0.8s | 50-100 | 0.8 |
| Level Up | 64 | 1.5s | 100-200 | 0.9 |
| Hit | 24 | 0.5s | 80-150 | 1.0 |
| Mutation | 40 | 1.2s | 40-80 | 0.7 |
| Scan Wave | 48 | 1.0s | 100-200 | 0.8 |
| Dash Trail | 16 | 0.4s | 0-10 | 0.3 |
| Propagation | 36 | 1.0s | 60-120 | 0.7 |

**Total particules par événement:** ~300
**Performance:** Légère (< 1ms sur hardware moderne)

---

## 🎯 Quick Test

Pour tester rapidement toutes les particules:

```gdscript
# Dans la console de debug (F1)
func test_all_particles():
	var pos = GameManager.virus_node.global_position
	await get_tree().create_timer(0.5).timeout
	ParticleManager.spawn_particle("infection", pos)
	
	await get_tree().create_timer(0.5).timeout
	ParticleManager.spawn_particle("level_up", pos)
	
	await get_tree().create_timer(0.5).timeout
	ParticleManager.spawn_particle("virus_hit", pos)
	
	await get_tree().create_timer(0.5).timeout
	ParticleManager.spawn_particle("mutation_activated", pos)
	
	await get_tree().create_timer(0.5).timeout
	ParticleManager.spawn_particle("scan_wave", pos)
	
	await get_tree().create_timer(0.5).timeout
	ParticleManager.spawn_particle("dash_trail", pos)
	
	await get_tree().create_timer(0.5).timeout
	ParticleManager.spawn_particle("propagation", pos)
```

Ou plus simple, jouez et:
1. Infectez un fichier → particules vertes ✅
2. Montez de niveau → explosion cyan ✅
3. Prenez des dégâts → glitch rouge ✅
4. Activez une mutation → spirale magenta ✅
5. Déclenchez un scan → onde orange ✅

---

## 🚀 Prochaines Étapes

Une fois les particules installées:

1. **ScreenShakeManager** (1h) - Ajoute du punch !
2. **NotificationManager** (1-2h) - Affiche les messages
3. **Trail du Virus** - Line2D qui suit le virus
4. **Glow Shader** - Effet néon sur le virus

Ces 4 améliorations transformeront complètement le feedback visuel ! 🎨

---

**Installation complète:** ~5 minutes  
**Impact visuel:** ⭐⭐⭐⭐⭐  
**Performance:** Léger  
**Difficulté:** Facile  

**Bon particules ! 🎨**
