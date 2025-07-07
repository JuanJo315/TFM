extends Node2D

@onready var actividad: Node2D = $Actividad

var current_interactions := []
var can_interact := true 

func _process(_delta: float) -> void:
	if current_interactions.size() > 0 and can_interact:
		current_interactions = current_interactions.filter(
			func(a): return a != null and a.has_method("is_interactable") and a.is_interactable
		)
		current_interactions.sort_custom(_sort_by_nearest)
		actividad.show()
	else:
		actividad.hide()
	
func interact_with_closest() -> void:
	if current_interactions.size() == 0 or not can_interact:
		return
	can_interact = false
	actividad.show()
	await current_interactions[0].interact.call()
	can_interact = true

func _sort_by_nearest(area1, area2): 
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.has_method("interact") and area.has_method("is_interactable"):
		current_interactions.push_back(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
