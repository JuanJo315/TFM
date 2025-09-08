extends Control

@onready var number_npcs: SpinBox = $MarginContainer/VBoxContainer/GridContainer/NPCsNumber
@onready var simulation_time: SpinBox = $MarginContainer/VBoxContainer/GridContainer/SimulationTime
@onready var time_scale: SpinBox = $MarginContainer/VBoxContainer/GridContainer/TimeScale

func _on_button_pressed() -> void:
	# 4.4 Godot SpinBox uses .value so this doesn't work 
	# CustomModeManager.simulated_npcs = number_npcs
	# CustomModeManager.simulation_duration = simulation_time
	# CustomModeManager.time_ratio = time_scale
	
	# So we do this 
	CustomModeManager.simulated_npcs = int(number_npcs.value)
	CustomModeManager.simulation_duration = int(simulation_time.value)
	CustomModeManager.time_ratio = int(time_scale.value)
	
	# Now we initialize the CustomModeManager variables 
	CustomModeManager.npcs.clear()
	CustomModeManager.edit_count = 0
	CustomModeManager.current_editing_index = -1
	
	# So we know it's the full loop and not add one from list 
	CustomModeManager.add_npc = false
	
	SceneManager.change_scene("res://Custom Mode/character_menu.tscn")
