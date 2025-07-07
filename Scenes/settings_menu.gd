extends Control

func _on_trial_map_pressed() -> void:
	print("Volume")


func _on_set_map_pressed() -> void:
	print("Resolution")


func _on_custom_map_pressed() -> void:
	print("Language")


func _on_settings_pressed() -> void:
	print("User Manual")


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu2.tscn")
