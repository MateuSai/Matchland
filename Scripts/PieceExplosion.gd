extends "res://Scripts/Particle.gd"

onready var destroySound: AudioStreamPlayer = get_node("DestroySound")

func _ready() -> void:
	destroySound.play()

