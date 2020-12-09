extends Sprite

onready var sizeTween: Tween = get_node("SizeTween")
onready var colorTween: Tween = get_node("ColorTween")

func _ready() -> void:
	setup(texture)


func setup(new_texture: Texture) -> void:
	texture = new_texture
	slowly_larger()
	slowly_dimmer()
	
	
func slowly_larger() -> void:
	sizeTween.interpolate_property(self, "scale", Vector2(1, 1), Vector2(1.8, 1.8), 2.3, Tween.TRANS_SINE,
								   Tween.EASE_OUT)
	sizeTween.start()
	
	
func slowly_dimmer() -> void:
	colorTween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2.3,
									Tween.TRANS_SINE, Tween.EASE_OUT)
	colorTween.start()


func _on_SizeTween_tween_completed(_object: Object, _key: NodePath) -> void:
	slowly_larger()


func _on_ColorTween_tween_completed(_object: Object, _key: NodePath) -> void:
	slowly_dimmer()
