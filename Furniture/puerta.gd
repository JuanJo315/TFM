extends StaticBody2D

@onready var interactable_area: Area2D = $InteractableArea
@onready var door_collision: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	interactable_area.interact = _on_interact
	

func _on_interact():
	sprite_2d.frame = 1 
	door_collision.disabled = true
