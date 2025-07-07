extends Node

# Create an array for the character's color 
var color_options = [
	Color(1, 1, 1), # Default
	Color.RED, 
	Color.BLUE, 
	Color.YELLOW, 
	Color.LIME_GREEN, 
	Color.GRAY 
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
var character_name = ""
var character_role = ""
var character_color = ""
