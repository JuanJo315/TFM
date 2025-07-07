extends Node2D

@export_enum("black", "brown") var alfombra: int 

@onready var sprite_2d: Sprite2D = $Sprite2D

func _process(_delta: float) -> void:
	match alfombra:
		0: 
			sprite_2d.frame = 0
		1: 
			sprite_2d.frame = 1
	
