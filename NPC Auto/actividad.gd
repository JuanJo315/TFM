extends Node2D

@onready var activity: Sprite2D = $Activity

# The sprite will change according to the object interacted 
func _physics_process(_delta: float) -> void:
	activity.frame = ActivitySingleton.activity_frames
