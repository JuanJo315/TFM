extends CharacterBody2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
var movement_speed := 50.0

func _ready():
	var nav_map_rid = $"../Floor".get_navigation_map()
	navigation_agent_2d.set_navigation_map(nav_map_rid)
	navigation_agent_2d.path_desired_distance = 4.0
	navigation_agent_2d.avoidance_enabled = false

func _physics_process(_delta: float) -> void:
	if navigation_agent_2d.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_position = navigation_agent_2d.get_next_path_position()
		var direction = (next_path_position - global_position).normalized()
		velocity = velocity.lerp(direction * movement_speed, 0.2)
		move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("RightClick"):
		var mouse_position = get_global_mouse_position()
		navigation_agent_2d.target_position = mouse_position
