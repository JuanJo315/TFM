extends StaticBody2D

@onready var area: Area2D = $InteractableAreaObject

# Tarea propia de este mueble (cámbiala en el Inspector).
@export var task: int = WaypointsTasks.tasks.REST

func _ready() -> void:
	# Garantiza pertenencia al grupo Waypoint en el PADRE
	if not is_in_group("Waypoint"):
		add_to_group("Waypoint")

	# Cuando el NPC “usa” este mueble, fija el sprite/animación
	area.interact = func():
		ActivitySingleton.activity_frames = WaypointsTasks.frame_for_task(task)

# Lógica de permisos por rol centralizada en WaypointsTasks
func valid_for_role(role: String) -> bool:
	return WaypointsTasks.can_role_use(task, role)
