extends Control

# Se elimina ya que he quitado el nodo CanvasLayer
# @onready var list_container = $CanvasLayer/ScrollContainer/VBoxContainer
@onready var scroll = $ScrollCards
@onready var list_container = $ScrollCards/CardNPC
@onready var npc_tracker = $ColorRect/HBoxContainer/Label2

const NPC_ROW_SCENE = preload("res://Custom Mode/npc_row.tscn")

func _ready() -> void:
	# We check the containers to be full 
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	_populate()
	
	update_tracker()

# We create a tracker for current and maximum NPCs 
func update_tracker() -> void:
	npc_tracker.text = " %d / %d" % [
		CustomModeManager.npcs.size(),
		CustomModeManager.simulated_npcs
	]

func _clear_list() -> void:
	for contained in list_container.get_children():
		contained.queue_free()

func _populate() -> void:
	_clear_list()
	
	var count = CustomModeManager.npcs.size()
	
	# Debug Print 
	print("NPCs:", CustomModeManager.npcs.size()) 
	
	# for i in CustomModeManager.npcs.size(): 
	for i in count:
		var row := NPC_ROW_SCENE.instantiate() as Control
		
		# We force the npc_row scene to show as the right size 
		row.clip_contents = false
		
		# Minimum Row Size 
		row.custom_minimum_size = Vector2(0, 120)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		list_container.add_child(row)
		row.set_data(CustomModeManager.npcs[i], i)
		row.edit_requested.connect(_on_row_edit)
		row.delete_requested.connect(_on_row_delete)
		
	update_tracker()
	
# When Editing it opens the character menu with preloaded data 
func _on_row_edit(index: int) -> void:
	if index >= 0 and index < CustomModeManager.npcs.size():
		CustomModeManager.current_editing_index = index 
		SceneManager.change_scene("res://Custom Mode/character_menu.tscn")
	
# When Eliminating we erase, update counter and refresh scene  
func _on_row_delete(index: int) -> void:
	if index >= 0 and index < CustomModeManager.npcs.size():
		CustomModeManager.npcs.remove_at(index) 
		CustomModeManager.edit_count = CustomModeManager.npcs.size()
		_populate()
	
# Button to add a new NPC to the list 
func _on_add_npc_button_pressed() -> void:
	if CustomModeManager.npcs.size() < CustomModeManager.simulated_npcs:
		CustomModeManager.current_editing_index = -1 
		
		# So we only add 1 NPC
		CustomModeManager.add_npc = true 
		
		SceneManager.change_scene("res://Custom Mode/character_menu.tscn")
	else:
		push_warning("Alcanzaste el número configurado de NPCs")

func _on_confirm_pressed() -> void:
	# SceneManager.change_scene("res://Scenes/work_in_progress.tscn")
	SceneManager.change_scene("res://Custom Mode/custom_mode_office.tscn")


func _on_add_missing_pressed() -> void:
	if CustomModeManager.npcs.size() < CustomModeManager.simulated_npcs:
		CustomModeManager.current_editing_index = -1 
		
		SceneManager.change_scene("res://Custom Mode/character_menu.tscn")
	else:
		push_warning("Alcanzaste el número configurado de NPCs")
