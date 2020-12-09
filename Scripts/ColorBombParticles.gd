extends "res://Scripts/Particle.gd"

onready var child_particles: Particles2D = get_node("Particles2D")
onready var sound: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _ready() -> void:
	child_particles.one_shot = true
	child_particles.emitting = true
	sound.play()

