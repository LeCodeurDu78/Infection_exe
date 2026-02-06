extends Control

@onready var xp_label := $Infection/XPLabel
@onready var threat_label := $Infection/ThreatLabel
@onready var mutation_manager := get_tree().root.get_node("Main/VirusSpawner/Virus/MutationManager") as MutationManager

func _process(_delta):
	var points := GameManager.get_virus_xp()
	xp_label.text = "XP : " + points	

	# Ajoute si tu as un label pour les points :
	#$ScoreLabel.text = "Data Volée : %d" % GameManager.points 

	match GameManager.get_threat_level():
		GameManager.ThreatLevel.LOW:
			threat_label.text = "Menace : FAIBLE"
			threat_label.modulate = Color.GREEN

		GameManager.ThreatLevel.MEDIUM:
			threat_label.text = "Menace : MOYENNE"
			threat_label.modulate = Color.ORANGE

		GameManager.ThreatLevel.CRITICAL:
			threat_label.text = "Menace : CRITIQUE"
			threat_label.modulate = Color.RED

	for i in range(1, 6):
		var progress = $MutationsCooldowns.get_node("MutationCooldown" + str(i))
		progress.modulate = Color(1, 1, 1, 0)

	if mutation_manager:
		var cooldowns := mutation_manager.get_all_cooldowns()
		var max_cooldowns := mutation_manager.get_all_max_cooldowns()
		
		if cooldowns.size() > 0:
			for i in range(len(cooldowns)):
				var cooldown = cooldowns.get("mutation" + str(i + 1), 1)
				if cooldown <= 0:
					continue
					
				var progress = $MutationsCooldowns.get_node("MutationCooldown" + str(i + 1))
			
				var max_cooldown = max_cooldowns.get("mutation" + str(i + 1), 1)
				progress.value = cooldown / max_cooldown * 100 
				progress.modulate = Color(1, 1, 1, 1)
