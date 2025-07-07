extends Node2D

@export_enum("brown_side", "brown_cross", "black_side", "black_cross") var alfombra: int 

@onready var sprite_2d: Sprite2D = $Sprite2D

func _process(_delta: float) -> void:
	match alfombra:
		0: 
			sprite_2d.frame = 0
		1: 
			sprite_2d.frame = 2
		2: 
			sprite_2d.frame = 1
		3: 
			sprite_2d.frame = 3
	
