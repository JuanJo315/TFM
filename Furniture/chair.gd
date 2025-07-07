extends StaticBody2D

@export_enum("Side_left", "Side_right", "Back", "Front") var chair: int 

@onready var sprite_2d: Sprite2D = $Sprite2D

func _process(_delta: float) -> void:
	match chair:
		0: 
			sprite_2d.frame = 6
		1: 
			sprite_2d.frame = 6
			sprite_2d.flip_h = true
		2: 
			sprite_2d.frame = 7
		3: 
			sprite_2d.frame = 8
	
