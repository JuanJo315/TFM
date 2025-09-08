extends Control

@onready var title: Label                = $ColorRect/Title
@onready var percent_mood: Label         = $ColorRect/Stats/Mood/Percent
@onready var percent_hunger: Label       = $ColorRect/Stats/Hunger/Percent
@onready var percent_thirst: Label       = $ColorRect/Stats/Thirst/Percent

@onready var name_label: Label           = $ColorRect/Information/HBoxContainer/Name/Label
@onready var role_label: Label           = $ColorRect/Information/HBoxContainer/Role/Label
@onready var color_label: Label          = $ColorRect/Information/HBoxContainer/Color/Label

# NPC to color
@onready var character_tex: TextureRect  = $ColorRect/Character

# Estos dos se usaban pero no estaban declarados
@onready var location_lbl: Label         = $ColorRect/Information/CurrentLocation/Label
@onready var finished_lbl: Label         = $ColorRect/Information/DoneTasks

var observed_npc: CustomNPC = null

@export var screen_offset: Vector2 = Vector2(12, -84) # a la derecha y encima del NPC
@export var clamp_to_screen: bool = true
@export var clamp_margin: int = 8

@onready var current_task_lbl: Label = $ColorRect/Information/CurrentTask/Label
@onready var todo_lbl: Label         = $ColorRect/Information/Assignments/Label
@onready var done_lbl: Label         = $ColorRect/Information/DoneTasks

func _ready() -> void:
	visible = false
	
	# Más fiable para teclas globales si hay GUI delante:
	set_process_unhandled_input(true)
	
	#set_process_input(true)
	if not CustomModeManager.current_runtime_changed.is_connected(_on_runtime_changed):
		CustomModeManager.current_runtime_changed.connect(_on_runtime_changed)
	_bind(CustomModeManager.get_current_runtime())

# Usa _unhandled_input para que no te lo “coma” ningún Control
func _unhandled_input(event: InputEvent) -> void:
#func _input(event: InputEvent) -> void:
	if event.is_action_pressed("see_stats"): # T
		visible = not visible
		if visible:
			_bind(CustomModeManager.get_current_runtime())
			_update_all()
		else:
			_unhook()
		
		# Consumimos el evento para que no haga nada más
		get_viewport().set_input_as_handled()

func _on_runtime_changed(npc: Node) -> void:
	if visible:
		_bind(npc)
		_update_all()

func _bind(npc: Node) -> void:
	_unhook()
	if npc is CustomNPC:
		observed_npc = npc
		if not observed_npc.stats_changed.is_connected(_on_stats_changed):
			observed_npc.stats_changed.connect(_on_stats_changed)
		if not observed_npc.task_changed.is_connected(_on_task_changed):
			observed_npc.task_changed.connect(_on_task_changed)
			# --- ADD ---
		if not observed_npc.assignments_changed.is_connected(_refresh_tasks):
			observed_npc.assignments_changed.connect(_refresh_tasks)
		# --- END ADD ---

func _unhook() -> void:
	if observed_npc:
		if observed_npc.stats_changed.is_connected(_on_stats_changed):
			observed_npc.stats_changed.disconnect(_on_stats_changed)
		if observed_npc.task_changed.is_connected(_on_task_changed):
			observed_npc.task_changed.disconnect(_on_task_changed)
	observed_npc = null

func _on_stats_changed() -> void:
	if visible:
		_update_stats()

func _on_task_changed(current_task: String) -> void:
	if visible:
		title.text = "Employee — " + current_task
		
		
		if is_instance_valid(current_task_lbl):
			current_task_lbl.text = current_task

func _update_all() -> void:
	title.text = "Employee Information" if observed_npc else "Sin selección"
	_update_info()
	
	_refresh_tasks()
	
	_update_stats()

func _update_info() -> void:
	if observed_npc:
		name_label.text  = String(observed_npc.character_name)
		role_label.text  = String(observed_npc.role)
		color_label.text = "#" + observed_npc.character_color.to_html(false)
		
		# colorear la imagen de la ficha
		character_tex.modulate = observed_npc.character_color
	else:
		name_label.text = "-"
		role_label.text = "-"
		color_label.text = "-"
		character_tex.modulate = Color.WHITE

func _update_stats() -> void:
	if observed_npc:
		percent_mood.text   = "%d %%" % int(round(observed_npc.mood))
		percent_hunger.text = "%d %%" % int(round(observed_npc.hunger))
		percent_thirst.text = "%d %%" % int(round(observed_npc.thirst))
	else:
		percent_mood.text = "0 %"
		percent_hunger.text = "0 %"
		percent_thirst.text = "0 %"

func _process(_delta: float) -> void:
	if not visible or observed_npc == null or not is_instance_valid(observed_npc):
		return

	# 1) Mundo -> Pantalla (incluye cámara) usando el NPC
	var npc_screen: Vector2 = observed_npc.get_global_transform_with_canvas().origin
	
	# 2) Posicionar el panel en pantalla con offset
	global_position = npc_screen + screen_offset

	# 3) Mantener en pantalla (opcional)
	if clamp_to_screen:
		var vp_rect: Rect2i = get_viewport_rect()
		var gx: float = clamp(global_position.x, float(clamp_margin), float(vp_rect.size.x - clamp_margin - size.x))
		var gy: float = clamp(global_position.y, float(clamp_margin), float(vp_rect.size.y - clamp_margin - size.y))
		global_position = Vector2(gx, gy)

	# 4) Estado en vivo
	var reached: bool = observed_npc.navigation_agent_2d.is_target_reached()
	finished_lbl.text = "Objetivo alcanzado" if reached else "Desplazándose"

	# 5) Posición actual
	location_lbl.text = "x=%.0f, y=%.0f" % [observed_npc.global_position.x, observed_npc.global_position.y]


func _refresh_tasks() -> void:
	if not is_instance_valid(observed_npc):
		return
	var todo_names: Array[String] = []
	for t in observed_npc.assignments:
		todo_names.append(WaypointsTasks.name_for_task(int(t)))
	var done_names: Array[String] = []
	for t in observed_npc.done:
		done_names.append(WaypointsTasks.name_for_task(int(t)))

	if is_instance_valid(todo_lbl):
		# todo_lbl.text = todo_names.join(", ")
		todo_lbl.text = ", ".join(todo_names)   # <- FIX
	if is_instance_valid(done_lbl):
		# done_lbl.text = done_names.join(", ")
		done_lbl.text = ", ".join(done_names)   # <- FIX
