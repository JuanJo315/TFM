extends CharacterBody2D

# For the stat panel
class_name CustomNPC

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var debug_label: Label = $DebugLabel
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var wait_timer: Timer = $WaitTimer

@export var speed_min: float = 40.0
@export var speed_max: float = 80.0


# Data the Spawner will fill
@export var character_name: String = "" 
@export var role: String = "" 
@export var character_color: Color = Color.WHITE 


var speed: float = 100.0 
var waypoints: Array[Node2D] = []
var current_waypoint: int = -1


# Stat block 
signal stats_changed
signal task_changed(current_task: String)

@export var mood := 100.0
@export var hunger := 100.0
@export var thirst := 100.0

@export var decay_per_min_mood := 2.0
@export var decay_per_min_hunger := 5.0
@export var decay_per_min_thirst := 6.0

const CRIT := 20.0
var forced_task: int = -1 # When the priority goes down 


func _ready() -> void:
	# Paint the sprite according to color 
	animated_sprite_2d.modulate = character_color
	
	set_physics_process(false)
	setup()
	
	
	# conexiones seguras
	if not navigation_agent_2d.velocity_computed.is_connected(_on_navigation_agent_2d_velocity_computed):
		navigation_agent_2d.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	if not wait_timer.timeout.is_connected(_on_wait_timer_timeout):
		wait_timer.timeout.connect(_on_wait_timer_timeout)
	wait_timer.one_shot = true
	if wait_timer.wait_time <= 0.0:
		wait_timer.wait_time = 3.0  
	
	
	# en _ready() del NPC, después de obtener navigation_agent_2d
	navigation_agent_2d.avoidance_enabled = true
	navigation_agent_2d.radius = 8.0        # o el radio real del NPC
	# Este agente evitará todo lo que esté en el bit 2 (Obstacles)
	navigation_agent_2d.avoidance_mask = 1 << 1
	# (opcional) si usas capas para agentes también:
	# navigation_agent_2d.avoidance_layers = 1 << 0  # "Agents"

	
	call_deferred("late_init")

func late_init() -> void:
	set_physics_process(true)


# In case the Waypoint is in Area2D 
func _resolve_waypoint_node(n: Node) -> Node2D:
	if n is Area2D:
		return n as Node2D
	var ia := n.get_node_or_null("InteractableAreaObject")
	if ia and ia is Area2D:
		return ia as Node2D
	return null


func setup() -> void:
	speed = randf_range(speed_min, speed_max)
	
	# We check valid Waypoints for the Character's Role 
	waypoints.clear()
	
	for n in get_tree().get_nodes_in_group("Waypoint"):
		var wp: Node2D = _resolve_waypoint_node(n)
		if wp == null:
			continue
		if wp.has_method("valid_for_role") and not wp.valid_for_role(role):
			continue
		waypoints.append(wp)
		# if wp.has_method("valid_for_role") and wp.valid_for_role(role):
			# waypoints.append(wp as Node2D)

	if waypoints.is_empty():
		for n in get_tree().get_nodes_in_group("Waypoint"):
			var wp2: Node2D = _resolve_waypoint_node(n)
			if wp2:
				waypoints.append(wp2)
	
	# If there are less than 2 Waypoints there is no reason to navigate
	if waypoints.size() < 1:
		queue_free()
		return 
	
	# --- ADD: inicializa listas de tareas por hacer / hechas ---
	assignments.clear()
	done.clear()
	for wp in waypoints:
		# var t := int(wp.get("task", -1))
		var t := _get_task(wp)         # <- FIX
		if t != -1 and not assignments.has(t):
			assignments.append(t)
	assignments_changed.emit()
# --- END ADD ---
	
	set_next_waypoint()

func set_next_waypoint() -> void:
	var valid_indices: Array[int] = []
	
	# If the NPC needs foo, water or rest, we prioritize that task 
	if forced_task != -1:
		for i in waypoints.size():
			if i == current_waypoint:
				continue
			var waypoint := waypoints[i]
			# mismo filtro de rol que ya usas
			if waypoint.has_method("valid_for_role") and not waypoint.valid_for_role(role):
				continue
			# leer propiedad exportada "task" del Area2D (no uses has_variable)
			# var task_val = waypoint.get("task")  # devuelve null si no existe
			var task_val := _get_task(waypoint)   # <- FIX
			if task_val == forced_task:
				valid_indices.append(i)

	# Else any task works 
	if valid_indices.is_empty():
		for i in waypoints.size():
			if i != current_waypoint:
				valid_indices.append(i)

	if valid_indices.is_empty():
		return
	
	current_waypoint = valid_indices.pick_random()
	navigation_agent_2d.target_position = (
		waypoints[current_waypoint].global_position
	)
	
	# --- ADD: notifica la tarea actual seleccionada ---
	# var t := int(waypoints[current_waypoint].get("task", -1))
	var t := _get_task(waypoints[current_waypoint])   # <- FIX
	if t != -1:
		task_changed.emit(WaypointsTasks.name_for_task(t))
	else:
		task_changed.emit("Normal")
# --- END ADD ---


func _physics_process(_delta: float) -> void:
	debug_label.text = "Done:%s\nHit target: %s\nTarget recheable:%s" % [
		navigation_agent_2d.is_navigation_finished(),
		navigation_agent_2d.is_target_reached(),
		navigation_agent_2d.is_target_reachable()
	]
	
	# manual_navigation()
	# navigate(delta)
	navigate_safe()

func navigate_safe() -> void: 
	if navigation_agent_2d.is_navigation_finished():
		# Stop moving
		velocity = Vector2.ZERO
		move_and_slide()
		
		# Arranca el timer y desactiva física YA,
		# para que pase lo que pase con la interacción, habrá continuidad.
		set_physics_process(false)
		wait_timer.start()
		
		var interact_node: Node = get_node_or_null("PlayerInteraction")
		_do_interact(interact_node)
		
		# --- ADD: registrar tarea realizada en este waypoint ---
		if current_waypoint >= 0 and current_waypoint < waypoints.size():
			var wp := waypoints[current_waypoint]
			# var t := int(wp.get("task", -1))
			var t := _get_task(wp)   # <- FIX
			if t != -1:
				if assignments.has(t):
					assignments.erase(t)
				if not done.has(t):
					done.append(t)
				assignments_changed.emit()
# --- END ADD ---
		
		
		# If the NPC goes to recover
		match forced_task:
			WaypointsTasks.tasks.WATER_DISPENSER:
				thirst = 100.0
			WaypointsTasks.tasks.FRIDGE:
				hunger = 100.0
			WaypointsTasks.tasks.REST:
				mood = 100.0
		
		# Then the NPC continues with his other tasks 
		if forced_task != -1:
			stats_changed.emit()
			task_changed.emit("Normal")
			forced_task = -1

		return
	
	var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
	navigation_agent_2d.velocity = new_velocity


# --- Helper para leer "task" con valor por defecto (SIN inferencias) ---
func _get_task(n: Object) -> int:
	var v: Variant = n.get("task")   # get() en 4.4 solo 1 parámetro
	if v == null:
		return -1
	if v is int:
		return v as int
	return int(v)
# ----------------------------------------------------------------------


# corrutina desacoplada (no bloquea navigate_safe)
func _do_interact(interact_node: Node) -> void:
	# Ignora errores de la interacción
	# await interact_node.interact_with_closest() if interact_node.has_method("interact_with_closest") else null
	if interact_node and interact_node.has_method("interact_with_closest"):
		await interact_node.interact_with_closest()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity 
	move_and_slide() 
	#animated_sprite_2d.rotation = lerp_angle(animated_sprite_2d.rotation, velocity.angle(), 0.1)


func _on_wait_timer_timeout() -> void:
	set_next_waypoint()
	set_physics_process(true)


func _process(delta: float) -> void:
	_update_stats(delta)

func _update_stats(delta: float) -> void:
	mood   = clamp(mood   - decay_per_min_mood   * (delta / 60.0), 0.0, 100.0)
	hunger = clamp(hunger - decay_per_min_hunger * (delta / 60.0), 0.0, 100.0)
	thirst = clamp(thirst - decay_per_min_thirst * (delta / 60.0), 0.0, 100.0)
	
	# Notifica cambios
	stats_changed.emit()
	
	# Elegir necesidad prioritaria
	var new_forced := -1
	if thirst <= CRIT: 
		new_forced = WaypointsTasks.tasks.WATER_DISPENSER
	elif hunger <= CRIT: 
		new_forced = WaypointsTasks.tasks.FRIDGE
	elif mood <= CRIT: 
		new_forced = WaypointsTasks.tasks.REST
	
	if new_forced != forced_task:
		forced_task = new_forced
		if forced_task != -1:
			task_changed.emit(_task_name(forced_task))
			set_next_waypoint()

func _task_name(t:int) -> String:
	match t:
		WaypointsTasks.tasks.WATER_DISPENSER: 
			return "Beber agua"
		WaypointsTasks.tasks.FRIDGE: 
			return "Comer"
		WaypointsTasks.tasks.REST: 
			return "Descansar"
		_: return "Normal"

# For the stat panel 
var assignments: Array[int] = []   # ids de WaypointDB.Task
var done: Array[int] = []
signal assignments_changed
