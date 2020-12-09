extends "res://Scripts/Particle.gd"

onready var mirrorParticles: Particles2D = get_node("Particles2D")
onready var sound: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _ready() -> void:
	mirrorParticles.one_shot = true
	mirrorParticles.emitting = true
	sound.play()

