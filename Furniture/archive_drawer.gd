extends StaticBody2D

@onready var interactable_area: Area2D = $InteractableAreaObject

func _ready() -> void:
	interactable_area.interact = _on_interact
	

func _on_interact():
	ActivitySingleton.activity_frames = 0
