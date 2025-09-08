extends Control

# Node reference for the text edit node 
@onready var name_box: TextEdit = $CanvasLayer/ColorRect/Name/TextEdit
@onready var sprite_2d: Sprite2D = $ColorRect/Character/Sprite2D
#@onready var role_edit: TextEdit = $CanvasLayer/ColorRect/Rol/TextEdit
@onready var role_label: Label = $CanvasLayer/ColorRect/Rol/Rol

# To show current NPC edit 
@onready var npc_number: Label = $CanvasLayer/ColorRect/NumberNPC/Label

# 2 new variables to keep track of the current 
# selected role sprite and color 
var current_role_index = 0
var current_color_index = 0

func _ready():
	# update_character()
	
	# Now we change between editing an already made NPC 
	if CustomModeManager.current_editing_index >= 0:
		var npc = CustomModeManager.npcs[CustomModeManager.current_editing_index]
		name_box.text = str(npc["name"]) 
		current_role_index = max(0, CustomCharacter.role_options.find(npc["role"]))
		current_color_index = max(0, CustomCharacter.color_options.find(npc["color"]))
		npc_number.text = "Editando NPC %d" % (CustomModeManager.current_editing_index + 1)
	
	# And editing a new NPC in the loop (initialize first)
	else: 
		name_box.text = "" 
		current_role_index = 0 
		current_color_index = 0 
		npc_number.text = "NPC %d / %d" % [
			CustomModeManager.edit_count + 1,
			CustomModeManager.simulated_npcs
		]
	
	update_character()


func update_character():
	# Update character color
	var current_color = CustomCharacter.color_options[current_color_index]
	sprite_2d.modulate = current_color
	CustomCharacter.character_color = current_color

	# Update character role
	var current_role = CustomCharacter.role_options[current_role_index]
	role_label.text = current_role
	CustomCharacter.character_role = current_role

# Introduce player's name 
func _on_text_edit_name_changed() -> void:
	CustomCharacter.character_name = name_box.text

func _on_role_button_pressed() -> void:
	current_role_index = (current_role_index + 1) % CustomCharacter.role_options.size()
	update_character()

func _on_previous_role_button_pressed() -> void:
	# current_role_index = (current_role_index - 1) % CustomCharacter.role_options.size()
	current_role_index = wrapi(current_role_index - 1, 0, CustomCharacter.role_options.size())
	update_character()

func _on_color_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % CustomCharacter.color_options.size()
	update_character()

func _on_previous_color_button_pressed() -> void:
	# current_color_index = (current_color_index - 1) % CustomCharacter.color_options.size()
	current_color_index = wrapi(current_color_index - 1, 0, CustomCharacter.color_options.size())
	update_character()

func _on_button_pressed() -> void:
	# Previous route 
	# SceneManager.change_scene("res://Scenes/work_in_progress.tscn")
	
	# Config  NPC with set values 
	var npc = CustomModeManager.make_npc(
		# Not used in case user changes text value too fast 
		# or comes from an edit 
		# CustomCharacter.character_name
		name_box.text.strip_edges(),
		CustomCharacter.character_role,
		CustomCharacter.character_color,
	)
	
	# Simple Validate to avoid empty names 
	if npc["name"] == "":
		push_warning("El nombre no puede estar vacío")
		return 
	
	# When editing or creating an NPC from the list 
	if CustomModeManager.current_editing_index >= 0:
		CustomModeManager.npcs[CustomModeManager.current_editing_index] = npc
		CustomModeManager.current_editing_index = -1 
		SceneManager.change_scene("res://Custom Mode/workforce_list.tscn")
		return
	
	# New method to add 1 NPC from the list 
	if CustomModeManager.add_npc:
		CustomModeManager.npcs.append(npc)
		CustomModeManager.edit_count = CustomModeManager.npcs.size()
		CustomModeManager.add_npc = false 
		SceneManager.change_scene("res://Custom Mode/workforce_list.tscn")
		return 
	
	# New NPC addition inside the loop 
	CustomModeManager.npcs.append(npc)
	CustomModeManager.edit_count += 1
	
	# If the configured NPCs are less than the requested by 
	# the user, then we keep going 
	if CustomModeManager.edit_count < CustomModeManager.simulated_npcs:
		SceneManager.change_scene("res://Custom Mode/character_menu.tscn")
	else: 
		# Else we finish the loop and pass to the list 
		SceneManager.change_scene("res://Custom Mode/workforce_list.tscn")
	
