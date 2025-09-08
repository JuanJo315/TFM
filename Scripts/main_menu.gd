extends Control

func _on_trial_map_pressed() -> void:
	print("View Map")
	# get_tree().change_scene_to_file("res://Scenes/mapa_basico.tscn")
	SceneManager.change_scene("res://Scenes/mapa_basico.tscn")


func _on_set_map_pressed() -> void:
	print("Test Maps")
	# get_tree().change_scene_to_file("res://Scenes/main_menu3.tscn")
	SceneManager.change_scene("res://Scenes/main_menu3.tscn")


func _on_custom_map_pressed() -> void:
	print("Custom Map")
	# get_tree().change_scene_to_file("res://Scenes/character_menu.tscn")
	# SceneManager.change_scene("res://Scenes/character_menu.tscn") 
	SceneManager.change_scene("res://Custom Mode/custom_specs.tscn")


func _on_settings_pressed() -> void:
	print("Settings")
	# get_tree().change_scene_to_file("res://Scenes/settings_menu.tscn")
	SceneManager.change_scene("res://Settings/settings_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _ready(): 
	# Manually push the first scene since no one changes into it
	if SceneManager.scene_history.is_empty():
		SceneManager.scene_history.append("res://Scenes/main_menu2.tscn")
		
