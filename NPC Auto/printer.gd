extends StaticBody2D

@onready var interactable_area: Area2D = $InteractableAreaObject

# What roles can use this Waypoint 
@export var allowed_roles: Array[StringName] = ["Informático", "Becario"] 

func _ready() -> void:
	interactable_area.interact = _on_interact
	

func _on_interact():
	ActivitySingleton.activity_frames = 0


func valid_for_role(role: String) -> bool:
	# If the array is empty, anyone can use it 
	return allowed_roles.is_empty() or allowed_roles.has(role)
