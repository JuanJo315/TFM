extends Node

# A stack to keep track of scene paths:
var scene_history: Array[String] = []

func _input(event): 
	if event.is_action_pressed("go_back"): 
		go_back()
	if event.is_action_pressed("exit_game"): 
		get_tree().quit()
	
# Call this whenever you change scene normally:
func change_scene(path: String) -> void: 
	# scene_history.append(path) 
	# get_tree().change_scene_to_file(path)
	if get_tree().current_scene != null:
		scene_history.append(get_tree().current_scene.scene_file_path)
	call_deferred("_do_change_scene", path)

func go_back() -> void: 
	if scene_history.size() > 0: 
		# Pop / Remove current scene 
		# scene_history.pop_back() 
		var prev_path = scene_history.pop_back() 
		# Peek the new last, and switch to it 
		# var prev_path = scene_history.back() 
		call_deferred("_do_change_scene", prev_path)
	else:
		print("No previous scene to go back to.")

func _do_change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
	
