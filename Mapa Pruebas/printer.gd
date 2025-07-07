extends StaticBody2D

@onready var interactable_area: Area2D = $InteractableArea

func _ready() -> void:
	interactable_area.interact = _on_interact
	

func _on_interact():
	print("Player made a copy")
