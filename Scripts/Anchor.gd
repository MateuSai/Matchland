extends Sprite

var color: String = "anchor"
var bomb_type: int = 0
var matched: bool = false

onready var moveTween: Tween = $MoveTween
	
func move(final_position: Vector2) -> void:
	moveTween.interpolate_property(self, "position", position, final_position, 0.4,
								   Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	moveTween.start()
	
	
func match_and_dim() -> void:
	matched = true
	modulate = Color(1, 1, 1, 0.5)
