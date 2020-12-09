extends TextureButton

const TRANSPARENT_COLOR = Color(1, 1, 1, 0)
const FOCUS_COLOR = Color(1, 1, 1, 0.2)

func _ready() -> void:
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("toggled", self, "_on_button_toggled")
	modulate = TRANSPARENT_COLOR
	
	
func _on_mouse_entered() -> void:
	if not pressed:
		modulate = FOCUS_COLOR
	
	
func _on_mouse_exited() -> void:
	if not pressed:
		modulate = TRANSPARENT_COLOR
	
	
func _on_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		modulate = Color(0, 0, 0, 0.2)
	else:
		modulate = FOCUS_COLOR

