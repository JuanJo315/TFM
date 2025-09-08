extends Node

# Number of NPCs to Simulate 
var simulated_npcs: int = 0

# Simulation Duration 
var simulation_duration: int = 10 

# Simulation Time Speed to IRL (30 to 1)
var time_ratio: int = 30 

# NPCs with their stats 
# Here we save a Dictionary with 
# [{name:String, role:String, color:Color}]
var npcs: Array = [] 

# Current number of confirmed NPCs in the new loop 
var edit_count = 0

# >=0 if we edit an existing one 
var current_editing_index

# We create a variable so we only add 1 NPC from the list 
var add_npc = false

# Now the function to create the NPC Dictionary 
func make_npc(name: String, role: String, color: Color) -> Dictionary:
	return { "name": name, "role": role, "color": color}


# Runtime Directory for Active NPCs and Selection 
signal current_runtime_changed(npc)

var runtime_npcs: Array[Node] = []
var current_runtime_index := -1

func register_runtime_npc(npc: Node) -> void:
	if runtime_npcs.has(npc): 
		return
	runtime_npcs.append(npc)
	if current_runtime_index == -1:
		current_runtime_index = 0
	current_runtime_changed.emit(get_current_runtime())

func unregister_runtime_npc(npc: Node) -> void:
	var i := runtime_npcs.find(npc)
	if i == -1: 
		return
	runtime_npcs.remove_at(i)
	if runtime_npcs.is_empty():
		current_runtime_index = -1
	else:
		current_runtime_index = clamp(current_runtime_index, 0, runtime_npcs.size() - 1)
	current_runtime_changed.emit(get_current_runtime())

func get_current_runtime() -> Node:
	if current_runtime_index >= 0 and current_runtime_index < runtime_npcs.size():
		return runtime_npcs[current_runtime_index]
	return null

func next_runtime() -> void:
	if runtime_npcs.is_empty(): 
		return
	current_runtime_index = (current_runtime_index + 1) % runtime_npcs.size()
	current_runtime_changed.emit(get_current_runtime())

func prev_runtime() -> void:
	if runtime_npcs.is_empty(): 
		return
	current_runtime_index = (current_runtime_index - 1 + runtime_npcs.size()) % runtime_npcs.size()
	current_runtime_changed.emit(get_current_runtime())
