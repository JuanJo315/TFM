extends Node2D

# NPC scene to instantiate 
@export var npc_scene: PackedScene 

# Path to the Characters' Container 
@export var npc_container: NodePath = NodePath("../Characters")  

var npc_spawn_points: Array[Marker2D] = []
var npc_spawn_index: int = 0
var npc_pending: Array = []

@onready var timer: Timer = $Timer

func _ready() -> void:
	# Checks only Marker2D children of the node Spawn 
	npc_spawn_points.clear()
	for child in get_children():
		if child is Marker2D:
			npc_spawn_points.append(child)
	
	# If there are no more NPCs to spawn 
	if npc_spawn_points.is_empty():
		push_error("Spawn: no hay hijos Marker2D (ascensores) para spawnear.")
		return

	# Queue of NPCs to instantiate 
	npc_pending = CustomModeManager.npcs.duplicate()
	if npc_pending.is_empty():
		# When there is nothing to spawn 
		
		push_warning("Spawn: no hay NPCs en cola (CustomModeManager.npcs vacío")
		
		return
	# We coonect the Timer signal 
	if not timer.timeout.is_connected(_on_timeout_spawn):
			timer.timeout.connect(_on_timeout_spawn)
		
	# We start the Timer after 5 seconds 
	timer.start()

func _on_timeout_spawn() -> void:
	if npc_pending.is_empty():
		timer.stop()
		return
	if npc_scene == null:
		push_error("Spawn: 'npc_scene' no asignado.")
		timer.stop()
		return

	var data: Dictionary = npc_pending.pop_front()

	# Instatiate the NPC
	var npc := npc_scene.instantiate() as CharacterBody2D

	# Rotate between Marker2D in "Spawn" node 
	var elevator: Marker2D = npc_spawn_points[npc_spawn_index % npc_spawn_points.size()]
	npc_spawn_index += 1

	# The NPC starting position is the spawn point position
	npc.global_position = elevator.global_position

	# Add NPC data
	"""
	npc.character_name = str(data.get("name", "")) 
	npc.role = str(data.get("role", "")) 
	npc.character_color = data.get("color", Color.WHITE)
	"""
	
	npc.set("character_name", str(data.get("name", "")))
	npc.set("role",           str(data.get("role", "")))
	npc.set("character_color", data.get("color", Color.WHITE))
	
	# Add to Character Container 
	var parent_node: Node = self
	if npc_container != NodePath(""):
		var target := get_node_or_null(npc_container)
		if target:
			parent_node = target
	parent_node.add_child(npc)
	
	CustomModeManager.register_runtime_npc(npc)
	npc.tree_exited.connect(func(): CustomModeManager.unregister_runtime_npc(npc))
	
