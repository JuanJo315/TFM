extends Control

@onready var npc_image = $Card/MarginContainer/HBoxContainer/TextureRect
@onready var npc_name = $Card/MarginContainer/HBoxContainer/Information/Name/NPCname
@onready var npc_role = $Card/MarginContainer/HBoxContainer/Information/Rol/NPCrol
@onready var npc_color = $Card/MarginContainer/HBoxContainer/Information/Color/NPCcolor

@onready var edit_button = $Card/MarginContainer/HBoxContainer/Information/VBoxContainer/Editar
@onready var delete_button = $Card/MarginContainer/HBoxContainer/Information/VBoxContainer/Eliminar

# Signals to communicate with the list script for edit and delete 
signal edit_requested(index: int)
signal delete_requested(index: int)

var _index: int = -1 

# Function to inyect the Dictionary and Index 
func set_data(npc: Dictionary, index: int) -> void:
	_index = index 
	npc_name.text = str(npc.get("name", ""))
	npc_role.text = str(npc.get("role", ""))
	
	# To modulate the color of the image 
	# we store the color in a variable 
	var color_npc = (npc.get("color", Color.WHITE) as Color)
	# npc_color.text = color_npc.to_html(false) 
	
	# We search for the color's name on the array 
	var color_index = CustomCharacter.color_options.find(color_npc)
	if color_index != -1:
		npc_color.text = CustomCharacter.color_names[color_index]
	else:
		# In case it is a color outside the set array 
		npc_color.text = color_npc.to_html(false)
	
	npc_image.modulate = color_npc
	

func _on_editar_pressed() -> void:
	edit_requested.emit(_index)

func _on_eliminar_pressed() -> void:
	delete_requested.emit(_index)
