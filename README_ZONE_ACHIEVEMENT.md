# 🗺️🏆 ZoneManager & AchievementManager

## Vue d'Ensemble

**2 systèmes de progression** pour transformer votre jeu en expérience Dead Cells style.

**Installation:** 20 minutes  
**Impact:** ⭐⭐⭐⭐⭐ (Transforme le jeu)  
**Difficulté:** Moyenne  

---

## 🗺️ ZoneManager - Système de Zones/Niveaux

Gestion de progression de zones façon Dead Cells / roguelite.

### Features
✅ **5 zones** progressives (Files → Processes → Network → Admin → Core)  
✅ **Déverrouillage** automatique des zones suivantes  
✅ **Multiplicateurs** (XP, menace) par zone  
✅ **Sauvegarde** automatique de la progression  
✅ **UI de sélection** de zones  
✅ **Statistiques** de complétion  

### Structure des Zones

```
1. Zone Fichiers ⭐
   └─→ 2. Processus ⭐⭐
       ├─→ 3. Réseau ⭐⭐⭐
       │   └─→ 4. Admin ⭐⭐⭐⭐
       └───────┘   └─→ 5. Core ⭐⭐⭐⭐⭐
```

### Configuration par Zone

| Zone | Difficulté | Infections | XP | Menace |
|------|-----------|------------|-----|--------|
| Files | ⭐ | 15 | x1.0 | x0.8 |
| Processes | ⭐⭐ | 20 | x1.2 | x1.0 |
| Network | ⭐⭐⭐ | 25 | x1.5 | x1.2 |
| Admin | ⭐⭐⭐⭐ | 30 | x2.0 | x1.5 |
| Core | ⭐⭐⭐⭐⭐ | 50 | x3.0 | x2.0 |

---

## 🏆 AchievementManager - Système d'Achievements

Système complet d'achievements/trophées avec tracking et UI.

### Features
✅ **16 achievements** prédéfinis  
✅ **4 catégories** (Progression, Infection, Combat, Vitesse)  
✅ **Progression** trackée automatiquement  
✅ **2 achievements secrets**  
✅ **UI élégante** avec liste et stats  
✅ **Notifications** à l'unlock  
✅ **Sauvegarde** avec date d'unlock  

### Catégories d'Achievements

**Progression (4):**
- 🦠 Premier Contact
- ⬆️ Évolution Complète  
- 🗺️ Explorateur Système
- 💎 Cœur du Système

**Infection (3):**
- 📁 Épidémie (100 fichiers)
- 🌐 Pandémie (500 fichiers)
- ✨ Infection Totale (100%)

**Combat (3):**
- 🛡️ Antivirus Killer (10 AV)
- 👻 Furtif (sans dégâts)
- ⚠️ Survivant (60s critique)

**Mutations (2):**
- 🧬 ADN Parfait
- 🔀 Multi-Mutation

**Vitesse (2):**
- ⚡ Vitesse Éclair (<2min)
- 🏃 Marathonien (1h)

**Secrets (2):**
- ❓ ???
- 💻 ???

---

## 🚀 Installation Rapide

### 3️⃣ AchievementManager (10 min)
4. Instancier AchievementPanel.tscn dans votre UI

**Voir INSTALLATION.md pour les détails complets**

---

## 💡 Utilisation Simple

### ZoneManager
```gdscript
# Démarrer une zone
ZoneManager.start_zone("files")

# Compléter une zone
ZoneManager.complete_zone("files", 100.0)

# Afficher sélecteur
var selector = load("res://Scenes/UI/ZoneSelector.tscn").instantiate()
add_child(selector)
selector.show_selector()

# Queries
var current = ZoneManager.get_current_zone()
print(current.name, " - Difficulté: ", current.difficulty)
```

### AchievementManager
```gdscript
# Débloquer
AchievementManager.unlock_achievement("first_infection")

# Progression
AchievementManager.add_progress("infect_100")

# Checks manuels
AchievementManager.check_speed_run(zone_time)
AchievementManager.check_no_damage(took_damage)

# Afficher panneau
$AchievementPanel.show_panel()

# Queries
var stats = AchievementManager.get_stats()
print("Achievements: %d/%d" % [stats.unlocked, stats.total])
```

---

## 🔗 Intégration Automatique

### ZoneManager
Les zones émettent automatiquement les événements EventBus et sauvegardent la progression via SaveManager.

### AchievementManager
Écoute automatiquement EventBus:
- `infection_completed` → +1 infections
- `virus_leveled_up` → Check level 5
- `zone_completed` → Check perfect infection
- `antivirus_destroyed` → +1 AV kills

**Aucune configuration manuelle requise !** 🎉

---

## 🎨 Aperçu Visuel

### Zone Selector
```
╔════════════════════════════════════════╗
║ 🗺️ SÉLECTION DE ZONE               [X]║
╠════════════════════════════════════════╣
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ Zone Fichiers          ⭐  ✅   │  ║
║ │ Zone de départ. Facile.          │  ║
║ │ Infections: 15 | XP: x1.0        │  ║
║ │              [Rejouer]           │  ║
║ └──────────────────────────────────┘  ║
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ Zone Processus     ⭐⭐  🔓     │  ║
║ │ Processus actifs. Scans fréquents│  ║
║ │ Infections: 20 | XP: x1.2        │  ║
║ │             [Commencer]          │  ║
║ └──────────────────────────────────┘  ║
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ Zone Réseau      ⭐⭐⭐  🔒     │  ║
║ │ Infrastructure réseau...         │  ║
║ │             [Verrouillée]        │  ║
║ └──────────────────────────────────┘  ║
╚════════════════════════════════════════╝
```

### Achievement Panel
```
╔════════════════════════════════════════╗
║ 🏆 ACHIEVEMENTS                    [X]║
║ Progression: 5 / 16 (31%)             ║
╠════════════════════════════════════════╣
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ 🦠  Premier Contact          ✅ │  ║
║ │     Infecter votre premier       │  ║
║ │     fichier                      │  ║
║ │     🕐 Débloqué le: 08/02/2026  │  ║
║ └──────────────────────────────────┘  ║
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ 📁  Épidémie                 🔒 │  ║
║ │     Infecter 100 fichiers        │  ║
║ │     ████████░░░░░░░░  45/100    │  ║
║ └──────────────────────────────────┘  ║
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ ❓  ???                       🔒 │  ║
║ │     Achievement secret - Non     │  ║
║ │     débloqué                     │  ║
║ └──────────────────────────────────┘  ║
╚════════════════════════════════════════╝
```

---

## 📊 Statistiques

### ZoneManager
- **Fichiers:** 5
- **Lignes de code:** ~250
- **Zones:** 5
- **Features:** Unlock, progression, save/load, UI

### AchievementManager
- **Fichiers:** 5
- **Lignes de code:** ~400
- **Achievements:** 16 (extensible)
- **Features:** Unlock, tracking, save/load, UI, secrets

**Total:** 10 fichiers, ~650 lignes, 21 features ! 📈

---

## 🎯 Impact sur le Jeu

### Avant
```
❌ Jeu linéaire (une zone)
❌ Pas de progression
❌ Pas de rejouabilité
❌ Pas d'objectifs
```

### Après
```
✅ 5 zones progressives
✅ Système d'unlocking
✅ 16 achievements
✅ Rejouabilité (speed run, perfect)
✅ Sauvegarde de progression
✅ Multiplicateurs de difficulté
```

**Transformation:** Jeu arcade → Jeu avec profondeur ! 🚀

---

## 🔧 Customisation

### Ajouter une Zone
```gdscript
var ma_zone := Zone.new(
    "ma_zone",
    "Ma Super Zone",
    3,  # Difficulté
    "res://Scenes/Zones/MaZone.tscn",
    "Description"
)
ma_zone.xp_multiplier = 1.5
zones["ma_zone"] = ma_zone
```

### Ajouter un Achievement
```gdscript
var mon_ach := Achievement.new(
    "mon_id",
    "Nom",
    "Description",
    "🎯"
)
mon_ach.target = 50  # Si progression
_add_achievement(mon_ach)
```

---

## 🐛 Commandes Debug

Ajoutez à DebugConsole:
```
zone <id>         - Téléporter vers zone
unlock_zones      - Débloquer toutes
achievements      - Stats achievements
unlock_ach <id>   - Débloquer achievement
```

---

## ✅ Checklist d'Installation

### ZoneManager
- [ ] Copier ZoneManager.gd
- [ ] Copier UI files (ZoneSelector, ZoneButton)
- [ ] Ajouter Autoload
- [ ] Créer 5 scènes de zones vides
- [ ] Ajouter signaux EventBus
- [ ] Tester avec `ZoneManager.start_zone("files")`

### AchievementManager
- [ ] Copier AchievementManager.gd
- [ ] Copier UI files (AchievementPanel, AchievementItem)
- [ ] Ajouter Autoload
- [ ] Instancier AchievementPanel dans UI
- [ ] Ajouter signaux EventBus
- [ ] Tester avec `AchievementManager.unlock_achievement("first_infection")`

---

## 🚀 Prochaines Étapes

Une fois installés:

**Court terme (Semaine 1):**
1. Remplir les 5 scènes de zones avec contenu
2. Créer le boss pour Core zone
3. Tester la progression complète

**Moyen terme (Semaine 2-3):**
4. Affiner les achievements (cibles, secrets)
5. Améliorer les UI de zones et achievements
6. Ajouter animations et particules

**Long terme (Mois 1):**
7. Balancing des difficultés
8. Contenu additionnel (zones bonus, achievements cachés)
9. Leaderboards et statistiques avancées

---

## 📚 Documentation

- **INSTALLATION.md** - Guide détaillé complet
- **Code source** - Commentaires dans chaque fichier
- **EventBus_additions.gd** - Signaux requis

---

**Version:** 1.0.0  
**Date:** 2026-02-09  
**Créé pour:** Infection.exe  
**Systèmes:** ZoneManager + AchievementManager  
**Status:** ✅ Production Ready

**Transformez votre jeu ! 🗺️🏆**
