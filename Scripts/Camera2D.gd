extends Camera2D

onready var shakeTween: Tween = get_node("ShakeTween")

func _on_Grid_place_camera(new_pos: Vector2) -> void:
	offset = new_pos


func _on_Grid_camera_effect() -> void:
	shakeTween.interpolate_property(self, "zoom", Vector2(0.97, 0.97), Vector2(1, 1), 0.2, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	shakeTween.start()
