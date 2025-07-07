extends Node2D

# Tamaño del tile, debe coincidir con el del TileMap
var tile_size = Vector2(32, 32)

func _process(_delta: float) -> void:
	# Obtiene la posición global del mouse, la ajusta y la redondea a la cuadrícula
	var mouse_pos = get_global_mouse_position() + tile_size / 2
	position = mouse_pos.snapped(tile_size) - tile_size / 2
