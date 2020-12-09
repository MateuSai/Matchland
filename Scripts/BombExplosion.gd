extends "res://Scripts/Particle.gd"

onready var sound: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _ready() -> void:
	sound.play()

