extends Node2D

@onready var actividad: Node2D = $Actividad

var current_interactions := []
var can_interact := true 

func _input(event: InputEvent) -> void:
	# Se comprueba que no está interactuando con otro objeto 
	if event.is_action_pressed("interact") and can_interact: 
		if current_interactions:
			can_interact = false 
			actividad.show()
			
			# Se busca cuantos elementos en el mapa 
			# son interactuables (interact Callable)
			await current_interactions[0].interact.call()
			
			can_interact = true 

# Se ordena el array de forma que las áreas más 
# cercanas están al principio del array 
# así el objeto con el que se interactúa es el 
# primero de la lista 
func _process(_delta: float) -> void:
	# Si hay interactuables 
	if current_interactions and can_interact: 
		current_interactions.sort_custom(_sort_by_nearest)
		# se comprueba que se puede interactuar con el más cercano
		if current_interactions[0].is_interactable: 
			pass
	else: 
		actividad.hide()
	

func _sort_by_nearest(area1, area2): 
	# Se saca la distancia a estas áreas 
	# para ordenar el array 
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

# Para que se muestre que se puede interactuar con el objeto
func _on_area_2d_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)

# Se elimina la IU que muestra la posible interacción 
func _on_area_2d_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
