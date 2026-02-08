# 🎮 GAME DESIGN DOCUMENT (GDD)

## Nom du jeu
**Infection.exe**

---

## 1. Pitch du jeu

*Virus Inside* est un jeu **2D action / stratégie** dans lequel le joueur incarne un **virus informatique** évoluant à l’intérieur d’un ordinateur. Le but est de **se propager, muter et prendre le contrôle du système**, tout en évitant un **antivirus intelligent et adaptatif**.

Le jeu mélange **réflexes**, **prise de décision**, **gestion du risque** et **montée en puissance**.

---

## 2. Plateforme & moteur

- **Plateforme** : PC
- **Moteur** : Godot 4.5
- **Vue** : 2D, top-down
- **Contrôles** : Clavier (manette possible plus tard)

---

## 3. Objectif du joueur

### Objectif principal
- Infecter **100 % du noyau (Core)** de l’ordinateur
- Neutraliser ou dépasser l’antivirus

### Objectifs secondaires
- Infecter un maximum de fichiers
- Débloquer toutes les mutations
- Survivre le plus longtemps possible

---

## 4. Gameplay Core Loop

1. Le joueur se déplace dans une zone
2. Il infecte des éléments
3. Il gagne des ressources
4. Il améliore son virus (mutations)
5. L’antivirus devient plus agressif
6. Le joueur prend des risques pour progresser
7. Accès à de nouvelles zones

➡️ Boucle répétée jusqu’à la victoire ou la défaite

---

## 5. Contrôles

- **Déplacement** : ZQSD / WASD / Flèches
- **Infecter** : Contact ou touche dédiée
- **Pouvoirs** : Touches 1, 2, 3
- **Pause** : Échap

---

## 6. Le Virus (joueur)

### Statistiques
- Vitesse
- Taux d’infection
- Discrétion
- Résistance

### Particularités
- Fragile mais rapide
- Peut se dupliquer
- Peut muter

---

## 7. Système d’infection

### Éléments infectables
- Fichiers
- Dossiers
- Processus
- Nœuds réseau
- Noyau (final)

### Effets d’une infection
- Change l’état visuel
- Produit des ressources
- Peut propager l’infection

---

## 8. Zones du jeu

### 1. Zone Fichiers
- Facile
- Peu défendue
- Faible gain

### 2. Zone Processus
- Éléments mobiles
- Infection plus difficile
- Gain moyen

### 3. Zone Réseau
- Propagation en chaîne
- Très rentable
- Fortement surveillée

### 4. Noyau (Core)
- Zone finale
- Antivirus maximal
- Objectif de victoire

---

## 9. Antivirus (ennemis)

### Types
- Antivirus mobile (chasse)
- Scan de zone
- Firewall
- Nettoyage système

### Intelligence adaptative
- Analyse le comportement du joueur
- Augmente la difficulté dynamiquement

---

## 10. Mutations (progression)

### Ressource
- Points de mutation gagnés via infection

### Exemples de mutations
- Infection plus rapide
- Invisibilité temporaire
- Propagation automatique
- Contrôle à distance
- Infection explosive

Le joueur choisit son style de jeu.

---

## 11. Risque / Récompense

- Zones sûres : progression lente
- Zones dangereuses : progression rapide
- Le joueur décide quand prendre des risques

---

## 12. Défaite

- Virus principal supprimé
- Plus aucune copie active
- Nettoyage total du système

---

## 13. Victoire

- Noyau infecté à 100 %
- Antivirus neutralisé
- Contrôle total de l’ordinateur

---

## 14. Direction artistique

- Style minimaliste
- Couleurs néon
- Fond sombre
- Effets de glitch et scanlines

---

## 15. Ambiance sonore

- Sons digitaux
- Effets de corruption
- Musique synth / cyber

---

## 16. Rejouabilité

- Carte semi-aléatoire
- Mutations différentes à chaque partie
- Antivirus imprévisible

---

## 17. Vision finale

*Virus Inside* doit donner au joueur la sensation de :
- Survie intelligente
- Montée en puissance
- Chaos contrôlé
- Lutte contre un système vivant

---

**Document évolutif – destiné à guider le développement du jeu**

