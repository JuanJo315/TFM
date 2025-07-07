extends StaticBody2D

@onready var lift_collision: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interactable_area: Area2D = $InteractableArea

func _ready() -> void:
	interactable_area.interact = _on_interact
	

func _on_interact():
	sprite_2d.frame = 1 
	lift_collision.disabled = true
