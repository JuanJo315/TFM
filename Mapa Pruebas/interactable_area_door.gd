extends Area2D

@export var is_interactable: bool = true

@export var is_door: bool = true

# Al hacer esta función un Callable, 
# se podrá llamar desde el nodo de interacción 
# del personaje 
var interact: Callable = func():
	pass
