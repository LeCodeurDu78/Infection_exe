# 🛡️ Guide d'Intégration - IA Antivirus Améliorée

## 📋 Fichiers Créés

### 1. **ImprovedAntivirus.gd** 
Remplace `Scripts/Enemies/Antivirus.gd`

**Nouvelles Fonctionnalités:**
- ✅ **5 États d'IA**: Patrol, Investigate, Chase, Coordinate, Deploy_Trap
- ✅ **Scans Intelligents**: Reactive, Predictive, Area Sweep, Coordinated
- ✅ **Système de Charges**: 3 charges de scan qui se rechargent
- ✅ **Patrouilles**: Parcours prédéfinis autour du spawn
- ✅ **Coordination**: Communication entre antivirus pour attaques en tenaille
- ✅ **Déploiement Stratégique**: Placement intelligent de firewalls
- ✅ **Mémoire**: Se souvient de la dernière position du virus
- ✅ **Feedback Visuel**: Couleur change selon l'état

### 2. **Firewall.gd** + **Firewall.tscn**
Nouveau: `Scripts/Enemies/Firewall.gd` + `Scenes/Enemies/Firewall.tscn`

**Fonctionnalités:**
- 🧱 Mur temporaire (8 secondes de vie)
- ⚠️ Phase d'avertissement (0.5s de flash orange)
- 💔 Inflige 10 dégâts/seconde au virus
- 🐌 Ralentit le virus (30% de vitesse)
- 💥 Peut être détruit par certaines mutations (100 HP)
- ✨ Effets de particules

### 3. **ImprovedScanZone.gd** + **ImprovedScanZone.tscn**
Remplace `Scripts/Enemies/ScanZone.gd` + scene

**Améliorations:**
- 📡 Pulse progressif (s'intensifie avant le scan)
- 🔴 Changement de couleur orange→rouge
- ⚡ Flash rapide dans les 0.5 dernières secondes
- 🎯 Dégâts par ticks (25 dmg toutes les 0.5s)
- 💫 Particules pendant le scan
- 📢 Notifications contextuelles

---

## 🔧 Intégration dans Votre Projet

### Étape 1: Remplacer l'Antivirus

1. **Copier le nouveau script:**
   ```
   ImprovedAntivirus.gd → Scripts/Enemies/Antivirus.gd
   ```

2. **Mettre à jour la scène Antivirus.tscn:**
   - Ouvrir `Scenes/Enemies/Antivirus.tscn`
   - Dans l'inspecteur du nœud racine, ajouter:
     - **Scanning > Firewall Scene**: `res://Scenes/Enemies/Firewall.tscn`
   
3. **Configurer les exports dans l'éditeur:**
   ```
   [Combat]
   - Base Speed: 200
   - Chase Speed Multiplier: 1.5
   - Damage: 75
   
   [Scanning]
   - Scan Cooldown: 4.0
   - Predictive Scan Enabled: true
   - Scan Prediction Time: 0.5
   
   [Intelligence]
   - Memory Duration: 5.0
   - Coordination Radius: 300
   - Trap Placement Enabled: true
   ```

### Étape 2: Ajouter le Firewall

1. **Copier les fichiers:**
   ```
   Firewall.gd → Scripts/Enemies/Firewall.gd
   Firewall.tscn → Scenes/Enemies/Firewall.tscn
   ```

2. **Vérifier la scène:**
   - Ouvrir `Firewall.tscn`
   - S'assurer que le script est bien lié
   - Le Rectangle.svg devrait être rouge semi-transparent

### Étape 3: Améliorer les ScanZones

1. **Remplacer le script:**
   ```
   ImprovedScanZone.gd → Scripts/Enemies/ScanZone.gd
   ```

2. **Mettre à jour la scène:**
   - Ouvrir votre ScanZone existante
   - Ajouter un nœud `Sprite2D` enfant nommé `WarningRing`
   - Lui assigner la même texture que le sprite principal
   - Ajouter un nœud `GPUParticles2D` nommé `Particles`
   - Configurer les particules selon la scène fournie

3. **Alternative rapide:**
   Remplacer toute la scène:
   ```
   ImprovedScanZone.tscn → Scenes/Enemies/ScanZone.tscn
   ```

### Étape 4: Lier le Firewall à l'Antivirus

Dans `Scenes/Enemies/Antivirus.tscn`:
1. Sélectionner le nœud racine `Antivirus`
2. Dans l'inspecteur, section **Scanning**
3. Glisser-déposer `Firewall.tscn` dans le champ **Firewall Scene**

---

## 🎮 Comportements Ajoutés

### 🤖 Patrouilles Intelligentes

L'antivirus crée automatiquement 4 points de patrouille en carré autour de son spawn:
- Attend 2 secondes à chaque point
- 30% de chance de déployer un firewall à chaque arrêt
- Retourne en patrouille après avoir perdu le virus

### 🔍 Types de Scans

1. **Reactive Scan** (Basique)
   - Lance au dernier emplacement connu du virus
   - Échelle: 1.0x

2. **Predictive Scan** (Intelligent)
   - Prédit le mouvement du virus (0.5s d'avance)
   - Échelle: 1.2x
   - Notification: "⚠️ Scan Prédictif Détecté!"

3. **Area Sweep** (Enquête)
   - Large scan circulaire lors d'une investigation
   - Échelle: 2.0x
   - Notification: "📡 Balayage de Zone!"

4. **Coordinated Scan** (Coordination)
   - Tous les antivirus proches scannent au même endroit
   - Échelle: 1.5x
   - Notification: "🚨 Scan Coordonné!"

### 🤝 Coordination Entre Antivirus

Quand plusieurs antivirus sont proches (< 300px):
- Passent en mode COORDINATE
- Effectuent des mouvements en tenaille
- Scans synchronisés
- Feedback visuel: modulation magenta

### 🧱 Déploiement de Firewalls

**Conditions de Déploiement:**
- Maximum 2 firewalls actifs simultanément
- Cooldown de 15 secondes entre déploiements
- Distance optimale: 150-300px du virus

**Position Stratégique:**
- Placé à 60% de la distance entre antivirus et virus
- Coupe la route d'évasion du joueur

---

## ⚙️ Configuration par Niveau de Menace

Le système s'adapte automatiquement:

### 🟢 Menace FAIBLE
- Vitesse: 100%
- Scans prédictifs: Désactivés
- Firewalls: Désactivés
- Cooldown scan: 4.0s

### 🟡 Menace MOYENNE
- Vitesse: 130%
- Scans prédictifs: ✅ Activés
- Firewalls: Désactivés
- Cooldown scan: 3.5s

### 🔴 Menace CRITIQUE
- Vitesse: 170%
- Scans prédictifs: ✅ Activés
- Firewalls: ✅ Activés
- Cooldown scan: 2.5s

---

## 🐛 Debug & Testing

### Commandes Console de Test

Ajoutez ces commandes à `DebugConsole.gd`:

```gdscript
"test_firewall": {
	"description": "Spawn firewall at cursor",
	"function": func(_args):
		var fw = load("res://Scenes/Enemies/Firewall.tscn").instantiate()
		fw.global_position = get_global_mouse_position()
		get_tree().current_scene.add_child(fw)
}

"test_scan": {
	"description": "Trigger scan at virus position",
	"function": func(_args):
		if GameManager.virus_node:
			var antiviruses = get_tree().get_nodes_in_group("antivirus")
			if not antiviruses.is_empty():
				antiviruses[0]._perform_predictive_scan()
}

"antivirus_state": {
	"description": "Show antivirus states",
	"function": func(_args):
		for av in get_tree().get_nodes_in_group("antivirus"):
			print("%s - State: %s" % [av.name, av.current_state])
}
```

### Vérifications Visuelles

1. **Patrouilles**: Les antivirus devraient faire des carrés
2. **Couleurs**:
   - Rouge: PATROL/CHASE
   - Orange: INVESTIGATE
   - Magenta: COORDINATE
   - Violet: DEPLOY_TRAP
3. **Firewalls**: Flash orange puis rouge solide
4. **Scans**: Pulse progressif orange→rouge

---

## 📊 Balancing Recommandé

### Si Trop Difficile:
```gdscript
# Dans Antivirus
scan_cooldown = 5.0  # Au lieu de 4.0
scan_prediction_time = 0.3  # Au lieu de 0.5
coordination_radius = 200.0  # Au lieu de 300.0

# Dans Firewall
lifetime = 6.0  # Au lieu de 8.0
damage_per_second = 8.0  # Au lieu de 10.0
```

### Si Trop Facile:
```gdscript
# Dans Antivirus
scan_cooldown = 3.0
MAX_FIREWALLS = 3  # Au lieu de 2
chase_speed_multiplier = 2.0  # Au lieu de 1.5

# Dans Firewall
lifetime = 10.0
damage_per_second = 15.0
```

---

## 🎯 Mutations Contre-Mesures Suggérées

Pour que le joueur ait des outils contre ces nouveaux systèmes:

### Contre Firewalls:
- **Firewall Bypass** (existante): Traverser les murs
- **Nouvelle: "Viral Breach"**: Détruit les firewalls instantanément
- **Nouvelle: "Phase Shift"**: Ignore collision firewall pendant 3s

### Contre Scans Prédictifs:
- **Invisible** (existante): Empêche détection
- **Nouvelle: "Erratic Movement"**: Mouvements imprévisibles
- **Nouvelle: "Decoy"**: Clone fantôme qui trompe la prédiction

### Contre Coordination:
- **Nouvelle: "EMP Burst"**: Désactive temporairement tous les antivirus proches
- **Nouvelle: "Chaos Signal"**: Fait combattre les antivirus entre eux

---

## 🚀 Prochaines Améliorations Possibles

1. **Barrières Dynamiques**: Firewalls qui se déplacent
2. **Scan Rotatif**: Balayage en rayon laser
3. **Antivirus Spécialisés**: Sniper (longue portée), Tank (lent mais costaud)
4. **Mode Essaim**: Tous les antivirus convergent sur le virus à haute menace
5. **Pièges Persistants**: Mines qui restent après mort de l'antivirus

---

## 📝 Notes Importantes

- ⚠️ Ne pas oublier d'assigner `firewall_scene` dans l'inspecteur
- ⚠️ Vérifier que les groupes "antivirus", "virus", "firewall" sont bien assignés
- ⚠️ Tester d'abord dans une zone simple avant intégration complète
- 💡 Les notifications peuvent être désactivées pour moins de spam

---

**Fait avec ❤️ pour Infection.exe**
Version: 1.0.0
Date: 2026
