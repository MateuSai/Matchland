extends TextureButton

export(int) var level: int = 0

onready var levelLavel: Label = get_node("LevelLabel")
onready var tween: Tween = get_node("Tween")
onready var completedMark: Sprite = get_node("CompletedMark")
onready var waitTimer: Timer = get_node("WaitTimer")
onready var completedMarkSound: AudioStreamPlayer = get_node("CompletedMarkSound")

func _ready() -> void:
	levelLavel.text = str(level)
	
	
func appear() -> void:
	tween.interpolate_property(self, "rect_scale", Vector2(0.7, 0.7), Vector2(1, 1), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	
	
func appear_completed_mark() -> void:
	waitTimer.start()
	yield(waitTimer, "timeout")
	
	var particles_path: PackedScene = preload("res://Scenes/Particles/LevelCompletedParticles.tscn")
	var particles: Particles2D = particles_path.instance()
	particles.position = completedMark.position - Vector2(7, 5)
	add_child(particles)
	
	yield(get_tree().create_timer(2), "timeout")
	
	completedMark.show()
	tween.interpolate_property(completedMark, "scale", Vector2(0.85, 0.85), Vector2(1, 1), 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	completedMarkSound.play()


func _on_LevelButton_pressed() -> void:
	SceneTransistor.change_scene("res://Scenes/Levels/Level " + str(level) + ".tscn")
