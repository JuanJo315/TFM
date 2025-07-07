extends CharacterBody2D

@export var speed = 150 # How fast the player will move (pixels/sec).

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var animated_sprite = $AnimatedSprite2D

var screen_size # Size of the game window.
var last_direction = "down" # Dirección por defecto para la animación de reposo

# Called when the node enters the scene tree for the first time.
func _ready():
	# We get the size of the screen like this
	# screen_size = get_viewport_rect().size
	call_deferred("actor_setup")
	animated_sprite.animation = "rest down" # Animación inicial
	# pass # 

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	navigation_agent_2d.set_target_position(get_global_mouse_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var movement_velocity = Vector2.ZERO # The player's movement vector. (0, 0)
	
	# Capturar entrada del usuario y actualizar la dirección
	if Input.is_action_pressed("move_right"):
		movement_velocity.x += 1
		last_direction = "right"
	elif Input.is_action_pressed("move_left"):
		movement_velocity.x -= 1
		last_direction = "left"
	elif Input.is_action_pressed("move_down"):
		movement_velocity.y += 1
		last_direction = "down"
	elif Input.is_action_pressed("move_up"):
		movement_velocity.y -= 1
		last_direction = "up"
	
	if movement_velocity.length() > 0:
		# To avoid the player from moving faster diagonally we normalize 
		# the velocity meaning we set the length to 1 
		movement_velocity = movement_velocity.normalized() * speed
		
		#Now we check if the player moves to animate the sprites 
		animated_sprite.play()
	else: 
		# Cambia a la animación de reposo basada en la última dirección 
		animated_sprite.animation = "rest " + last_direction
		animated_sprite.stop()

	# Asignar animación de caminata solo si hay movimiento
	if movement_velocity.x > 0:
		animated_sprite.animation = "walk right" 
	elif movement_velocity.x < 0:
		animated_sprite.animation = "walk left" 
	elif movement_velocity.y > 0:
		animated_sprite.animation = "walk down"
	elif movement_velocity.y < 0:
		animated_sprite.animation = "walk up"
	
	# Ajustar la rotación del RayCast2D basado en la dirección del movimiento
	match last_direction:
		"right":
			$RayCast2D.rotation_degrees = -90  # Derecha (por defecto)
		"left":
			$RayCast2D.rotation_degrees = 90  # Izquierda
		"down":
			$RayCast2D.rotation_degrees = 0  # Abajo
		"up":
			$RayCast2D.rotation_degrees = 180  # Arriba
	
	# Aplicar movimiento
	velocity = movement_velocity
	move_and_slide() 
