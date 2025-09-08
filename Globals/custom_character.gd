extends Node

# Create an array for the character's color 
var color_options: Array[Color] = [
	#Color(1, 1, 1), # Default
	Color.WHITE,
	Color.RED, 
	Color.BLUE, 
	Color.YELLOW, 
	Color.LIME_GREEN, 
	Color.GRAY 
]

# Create an array to show the color name in the menu
var color_names = [
	"Blanco", 
	"Rojo", 
	"Azul", 
	"Amarillo", 
	"Verde Lima", 
	"Gris"
]

# Create an array for the character's color 
var role_options = [
	"Jefe", 
	"Informático", 
	"Becario", 
	"Servicio al Cliente", 
	"Mantenimiento"
]

# Variables to hold the selected options for the player features 
var character_name: String = ""
var character_role: String = ""
var character_color: Color = Color.WHITE
