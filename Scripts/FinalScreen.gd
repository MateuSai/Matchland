extends CanvasModulate

var label_visible: bool = true

onready var tapLabel: Label = get_node("CanvasLayer/VBoxContainer/Label")
onready var labelTween: Tween = get_node("CanvasLayer/VBoxContainer/Label/LabelTween")
onready var particles: Particles2D = get_node("CanvasLayer/Particles2D")
onready var sound: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _ready() -> void:
	get_tree().paused = true
	hide_label()
	sound.play()
	particles.one_shot = true


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_touch"):
		get_tree().paused = false
		get_parent().initialize()
		queue_free()


func show_label() -> void:
	labelTween.interpolate_property(tapLabel, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.3,
									Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	labelTween.start()
	label_visible = true
	
	
func hide_label() -> void:
	labelTween.interpolate_property(tapLabel, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.3,
									Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	labelTween.start()
	label_visible = false


func _on_LabelTween_tween_completed(_object: Object, _key: NodePath) -> void:
	if label_visible:
		hide_label()
	else:
		show_label()
