extends Area2D

@export var is_interactable: bool = true

# Task of this Waypoint that will be overwritten in the furniture
var task: int = WaypointsTasks.tasks.ARCHIVE_DRAWER 

# By making this function a Callable, we can 
# call it from the NPC interaction node 
var interact: Callable = func():
	pass

func valid_for_role(role: String) -> bool: 
	return WaypointsTasks.can_role_use(task, role)

# func _ready() -> void: 
	# add_to_group("Waypoint")
