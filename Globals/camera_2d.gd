extends Camera2D

# Export so the zoom speed can be adjusted through the inspector 
@export var zoom_speed: float = 5.0

# Lock scenes where you can't tweak the camera 
@export var lock_scenes: Array[String] = [ 
	"res://Scenes/main_menu2.tscn", 
	"res://Scenes/main_menu3.tscn", 
	"res://Scenes/settings_menu.tscn", 
	"res://Scenes/character_menu.tscn"
]

# Same but with camera movement speed
#@export var camera_speed: float = 1.0

# So the zoom feature is smoother 
var zoom_target: Vector2

# Initial camera zoom and position 
var initial_zoom: Vector2
var initial_pos: Vector2

# Smoothing the camera 
#var cameraMove: Vector2 = Vector2.ZERO

# Now for the click and drag 
var drag_start_mouse_pos: Vector2 = Vector2.ZERO
var drag_start_camera_pos: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var camera_locked: bool = false

# Focus Mode 
var focus_enabled := false
var focus_target: Node2D = null
@export var follow_lerp := 8.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom_target = zoom
	initial_zoom = zoom
	initial_pos = position
	make_current()
	
	CustomModeManager.current_runtime_changed.connect(_on_current_npc_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Ignore camera changes if it's a locked scene 
	var current = get_tree().current_scene
	if current == null:
		return
	
	var current_path = current.scene_file_path
	
	# Check if the current scene is a locked scene
	if current_path in lock_scenes:
		# If true then the camera is set to its initial values
		reset_camera()
		return
	
	#zoom_in_out(delta)
	#simple_pan(delta)
	#click_and_drag()
	
	# Activate Focus Mode 
	if Input.is_action_just_pressed("focus_mode"):
		if focus_enabled: 
			_disable_focus()
		else: 
			_enable_focus()
	
	# Change focused NPC with arrow keys 
	if Input.is_action_just_pressed("ui_right"):
		CustomModeManager.next_runtime()
	if Input.is_action_just_pressed("ui_left"):
		CustomModeManager.prev_runtime()
	
	# Follow NPC
	if focus_enabled and is_instance_valid(focus_target):
		global_position = global_position.lerp(focus_target.global_position, clamp(follow_lerp * delta, 0.0, 1.0))
		return

	# If no Focus, then admits zoom and drag 
	zoom_in_out(delta)
	click_and_drag()
	
func zoom_in_out(delta): 
	#if !GameManager.filesystem_shown: 
		if Input.is_action_just_pressed("zoom_in"):
			zoom_target *= 1.1 
	
		if Input.is_action_just_pressed("zoom_out"):
			zoom_target *= 0.9
		
		if Input.is_action_just_pressed("reset_camera"):
			reset_camera()
	
		# Now so the zoom moves gradually to the target  
		zoom = zoom.slerp(zoom_target, zoom_speed * delta)

func click_and_drag(): 
	#if !GameManager.filesystem_shown: 
		if !is_dragging and Input.is_action_just_pressed("panoramic"):
			drag_start_mouse_pos = get_viewport().get_mouse_position() 
			drag_start_camera_pos = position 
			is_dragging = true
		
		if is_dragging and Input.is_action_just_released("panoramic"):
			is_dragging = false
		
		if is_dragging: 
			var move_vector = get_viewport().get_mouse_position() - drag_start_mouse_pos 
			position = drag_start_camera_pos - move_vector * (1/zoom.x)

func reset_camera():
	zoom_target = initial_zoom 
	zoom = initial_zoom 
	position = initial_pos

# When the watched NPC changes 
func _on_current_npc_changed(npc):
	if focus_enabled:
		focus_target = npc

# We habilitate Focus Mode 
func _enable_focus():
	var npc = CustomModeManager.get_current_runtime()
	if npc:
		focus_enabled = true
		focus_target = npc

# We disable Focus Mode 
func _disable_focus():
	focus_enabled = false
	focus_target = null
