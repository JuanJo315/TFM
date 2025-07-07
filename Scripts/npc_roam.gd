extends CharacterBody2D

# Estados del NPC
enum {
	IDLE,
	NEW_DIR,
	MOVE
}

# Constantes
const SPEED = 30  # Velocidad del NPC
const BOUNDARY_LIMIT = 100  # Límite del movimiento desde la posición inicial
const DIRECTIONS = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]  # Direcciones posibles

# Variables
var current_state = IDLE
var dir = Vector2.DOWN  # Dirección inicial (mirando hacia abajo)
var start_position  # Posición inicial del NPC

# Configuración inicial
func _ready():
	randomize()
	start_position = position
	$Timer.start()

# Elegir un elemento aleatorio de un array (corrige el error de solo lectura)
func choose(array):
	var temp_array = array.duplicate()  # Crear una copia del array
	temp_array.shuffle()  # Mezclar la copia
	return temp_array.front()  # Devolver el primer elemento

# Configurar la animación de reposo según la dirección
func set_idle_animation(direction):
	match direction:
		Vector2.RIGHT:
			$AnimatedSprite2D.animation = "rest right"
		Vector2.LEFT:
			$AnimatedSprite2D.animation = "rest left"
		Vector2.UP:
			$AnimatedSprite2D.animation = "rest up"
		Vector2.DOWN:
			$AnimatedSprite2D.animation = "rest down"
	$AnimatedSprite2D.play()

# Configurar la animación de caminar según la dirección
func set_walk_animation(direction):
	match direction:
		Vector2.RIGHT:
			$AnimatedSprite2D.animation = "walk right"
		Vector2.LEFT:
			$AnimatedSprite2D.animation = "walk left"
		Vector2.UP:
			$AnimatedSprite2D.animation = "walk up"
		Vector2.DOWN:
			$AnimatedSprite2D.animation = "walk down"
	$AnimatedSprite2D.play()

# Comprobar si el NPC ha alcanzado un límite
func reached_boundary():
	if position.x >= start_position.x + BOUNDARY_LIMIT:
		position.x = start_position.x + BOUNDARY_LIMIT - 0.1
		return true
	elif position.x <= start_position.x - BOUNDARY_LIMIT:
		position.x = start_position.x - BOUNDARY_LIMIT + 0.1
		return true
	elif position.y >= start_position.y + BOUNDARY_LIMIT:
		position.y = start_position.y + BOUNDARY_LIMIT - 0.1
		return true
	elif position.y <= start_position.y - BOUNDARY_LIMIT:
		position.y = start_position.y - BOUNDARY_LIMIT + 0.1
		return true
	return false

# Movimiento del NPC
func move(delta):
	position += dir * SPEED * delta
	set_walk_animation(dir)  # Configurar la animación de caminar
	if reached_boundary():  # Si se alcanza un límite, cambiar el estado
		current_state = NEW_DIR

# Gestión de estados del NPC
func _process(delta):
	match current_state:
		IDLE:
			set_idle_animation(dir)  # Configurar la animación de reposo
		NEW_DIR:
			dir = choose(DIRECTIONS)  # Elegir una nueva dirección aleatoria
			current_state = MOVE
		MOVE:
			move(delta)  # Mover al NPC

# Cambiar el estado del NPC periódicamente
func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1, 1.5])  # Duración aleatoria entre estados
	current_state = choose([IDLE, NEW_DIR])  # Cambiar entre IDLE o elegir nueva dirección
