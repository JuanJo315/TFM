extends CharacterBody2D

# const SPEED = 0  

var is_chatting = false
var player_in_chat_zone = false
var dialogue_started = false

enum State {
	IDLE
}

var current_state = State.IDLE
var player

func _ready():
	$AnimatedSprite2D.play("rest down")  

func _process(_delta): 
	if Input.is_action_just_pressed("chat")  and player_in_chat_zone: 
		print("chatting with NPC")
		$Dialogue.start()
		is_chatting = true 

func _on_chat_detection_body_entered(body: Node2D):
	if body.name == "Player":  # Cambiar esto según el nombre del nodo del jugador
		player = body
		player_in_chat_zone = true

func _on_chat_detection_body_exited(body: Node2D):
	if body.name == "Player":
		player_in_chat_zone = false

func _on_dialogo_dialogue_finished():
	is_chatting = false
	print("Diálogo finalizado.")
