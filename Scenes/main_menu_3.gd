extends Control

func _on_prototype_pressed() -> void:
	print("Prototype")
	# get_tree().change_scene_to_file("res://Scenes/mapa_prototipo.tscn")
	SceneManager.change_scene("res://Scenes/mapa_prototipo.tscn")

func _on_navigation_region_pressed() -> void:
	print("Navigation Region")
	# get_tree().change_scene_to_file("res://PlaceNavigation/mapa_navigation_region.tscn")
	SceneManager.change_scene("res://PlaceNavigation/mapa_navigation_region.tscn")

func _on_waypoint_search_pressed() -> void:
	print("Custom Map")
	# get_tree().change_scene_to_file("res://PlaceNavigation/mapa_waypoints.tscn")
	SceneManager.change_scene("res://PlaceNavigation/mapa_waypoints.tscn")

func _on_object_interaction_pressed() -> void:
	print("Office")
	# get_tree().change_scene_to_file("res://Interactions/mapa_interaction.tscn")
	SceneManager.change_scene("res://Interactions/mapa_interaction.tscn")

func _on_office_pressed() -> void:
	# get_tree().change_scene_to_file("res://NPC Auto/oficina.tscn")
	SceneManager.change_scene("res://NPC Auto/oficina.tscn")
