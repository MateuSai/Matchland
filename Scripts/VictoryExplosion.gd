extends "res://Scripts/Particle.gd"

const COLORS: Array = [
	Color(0, 0.9, 0),
	Color(0, 0.9, 0.9),
	Color(1, 0.5, 0),
	Color(1, 0, 0.5),
	Color(1, 0, 0),
	Color(0.4, 0, 0.8)
]

onready var sound: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _ready() -> void:
	process_material.color = COLORS[randi() % COLORS.size()]
	sound.play()

