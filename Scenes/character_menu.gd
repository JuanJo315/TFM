extends Node2D

# Node reference for the text edit node 
@onready var name_box = $CanvasLayer/ColorRect/Name/TextEdit
@onready var sprite_2d: Sprite2D = $ColorRect/Character/Sprite2D
#@onready var role_edit: TextEdit = $CanvasLayer/ColorRect/Rol/TextEdit
@onready var rol_label: Label = $CanvasLayer/ColorRect/Rol/Rol

# 2 new variables to keep track of the current 
# selected role sprite and color 
var current_role_index = 0
var current_color_index = 0

func _ready():
	update_character()

func update_character():
	# Update character color
	sprite_2d.modulate = CustomCharacter.color_options[current_color_index]
	CustomCharacter.character_color = CustomCharacter.color_options[current_color_index]

	# Update character role
	var current_role = CustomCharacter.role_options[current_role_index]
	rol_label.text = current_role
	CustomCharacter.character_role = current_role

# Introduce player's name 
func _on_text_edit_name_changed() -> void:
	CustomCharacter.character_name = name_box.text

func _on_role_button_pressed() -> void:
	current_role_index = (current_role_index + 1) % CustomCharacter.role_options.size()
	update_character()

func _on_previous_role_button_pressed() -> void:
	current_role_index = (current_role_index - 1) % CustomCharacter.role_options.size()
	update_character()

func _on_color_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % CustomCharacter.color_options.size()
	update_character()

func _on_previous_color_button_pressed() -> void:
	current_color_index = (current_color_index - 1) % CustomCharacter.color_options.size()
	update_character()

func _on_button_pressed() -> void:
	SceneManager.change_scene("res://NPC Auto/work_in_progress.tscn")
