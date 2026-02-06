extends Area2D
class_name Infectable

var infected := false
var is_virus_colliding := false
@export var points_worth := 10
@export var infection_time = 0.75

func _ready():
	GameManager.register_infectable()

func try_to_infect(virus_infection_rate: float):
	if infected:
		return
	await(get_tree().create_timer(infection_time / virus_infection_rate).timeout)
	
	if is_virus_colliding:
		infect()

func infect():
	if infected:
		return
	infected = true
	GameManager.on_infected(points_worth)
	queue_free()
	
func _on_area_entered(area):
	if area.name == "InfectionZone":
		is_virus_colliding = true
		try_to_infect(area.get_parent().infection_rate)

func _on_area_exited(area):
	if area.name == "InfectionZone":
		is_virus_colliding = false