extends TextureRect

const SPRITES: Array = [
	preload("res://Art/Pieces/Lightning.png/0.png"),
	preload("res://Art/Pieces/Lightning.png/1.png"),
	preload("res://Art/Pieces/Lightning.png/2.png")
]
var actual_sprite: int = 0

onready var sound: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _ready() -> void:
	sound.play()


func _on_Timer_timeout() -> void:
	if actual_sprite >= SPRITES.size() - 1:
		actual_sprite = 0
	else:
		actual_sprite += 1
		
	texture = SPRITES[actual_sprite]


func _on_DestroyTimer_timeout() -> void:
	queue_free()
