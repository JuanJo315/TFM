extends CharacterBody2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var debug_label: Label = $DebugLabel
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var speed_min: float = 40.0
@export var speed_max: float = 80.0

var speed: float = 100.0 
var waypoints: Array[Node2D] 
var current_waypoint: int = -1

func _ready() -> void:
	set_physics_process(false)
	setup()
	call_deferred("late_init")

func late_init() -> void:
	set_physics_process(true)

func setup() -> void:
	speed = randf_range(speed_min, speed_max)
	
	for waypoint in get_tree().get_nodes_in_group("Waypoint"):
		waypoints.append(waypoint as Node2D)
	
	if waypoints.size() < 2:
		queue_free()
	
	set_next_waypoint()

func set_next_waypoint() -> void:
	var valid_indices: Array[int] = []
	for i in waypoints.size():
		if i != current_waypoint:
			valid_indices.append(i)
	
	current_waypoint = valid_indices.pick_random()
	navigation_agent_2d.target_position = (
		waypoints[current_waypoint].global_position
	)

func _physics_process(_delta: float) -> void:
	debug_label.text = "Done:%s\nHit target: %s\nTarget recheable:%s" % [
		navigation_agent_2d.is_navigation_finished(),
		navigation_agent_2d.is_target_reached(),
		navigation_agent_2d.is_target_reachable()
	]
	
	manual_navigation()
	# navigate(delta)
	navigate_safe()

func manual_navigation() -> void: 
	if Input.is_action_just_pressed("set_target"):
		navigation_agent_2d.target_position = get_global_mouse_position()

func navigate() -> void: 
	if navigation_agent_2d.is_navigation_finished():
		return 
	var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()
	velocity = (
		global_position.direction_to(next_path_position) * speed
	)
	animated_sprite_2d.rotation = velocity.angle()
	move_and_slide() 

func navigate_safe() -> void: 
	if navigation_agent_2d.is_navigation_finished():
		set_next_waypoint()
	
	var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()
	var new_velocity: Vector2 = (
		global_position.direction_to(next_path_position) * speed
	)
	navigation_agent_2d.velocity = new_velocity

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity 
	move_and_slide() 
	animated_sprite_2d.rotation = lerp_angle(
		animated_sprite_2d.rotation, velocity.angle(), 0.1
	)
