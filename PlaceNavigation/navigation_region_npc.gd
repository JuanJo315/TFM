extends CharacterBody2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var debug_label: Label = $DebugLabel
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var speed: float = 100.0 

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

func navigate(_delta: float) -> void: 
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
		return 
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
