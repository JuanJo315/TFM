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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom_target = zoom
	initial_zoom = zoom
	initial_pos = position
	make_current()

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
	
	zoom_in_out(delta)
	#simple_pan(delta)
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
"""
func simple_pan(delta): 
	# We write the variable here because it wouldn't 
	# stop moving if placed outside the function 
	var camera_move: Vector2 = Vector2.ZERO
	
	
	if !GameManager.filesystem_shown: 
		if Input.is_action_pressed("KeyW"): 
			# position.y -= 1
			cameraMove.y -= camera_speed
		if Input.is_action_pressed("KeyS"): 
			cameraMove.y += camera_speed
		if Input.is_action_pressed("KeyA"): 
			cameraMove.x -= camera_speed
		if Input.is_action_pressed("KeyD"): 
			cameraMove.x += camera_speed 
	
	camera_move = camera_move.normalized()
	position += camera_move * delta * 1000 * (1/zoom.x)
"""

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
