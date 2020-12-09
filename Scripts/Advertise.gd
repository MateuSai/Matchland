extends CanvasModulate

var label_visible: bool = true
var is_shop_opened: bool = false

var shopUI: CanvasLayer = null

onready var label: Label = get_node("CanvasLayer/VBoxContainer/Label")
onready var labelTween: Tween = get_node("CanvasLayer/VBoxContainer/Label/LabelTween")
onready var shopButton: TextureButton = get_node("CanvasLayer/Shop")

func _ready() -> void:
	shopButton.connect("pressed", shopUI, "_on_Shop_pressed")
	shopUI.connect("closed", self, "_on_shopUI_closed")
	
	get_tree().paused = true
	hide_label()
	shopUI.advise_mode = true
	shopButton.disabled = false
	
	yield(get_tree().create_timer(0.6), "timeout")
	
	var particles_path:PackedScene = preload("res://Scenes/Particles/VictoryExplosion.tscn")
	for i in 6:
		var particles: Particles2D = particles_path.instance()
		particles.position = Vector2(rand_range(120, 200), rand_range(70, 110))
		get_node("CanvasLayer").add_child(particles)
		yield(get_tree().create_timer(rand_range(0.1, 0.2)), "timeout")
	
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_touch") and not is_shop_opened:
		var mouse: Vector2 = get_global_mouse_position()
		if (mouse.x < 233 or mouse.x > 253) and (mouse.y < 159 or mouse.y > 166):
			get_tree().paused = false
			shopUI.advise_mode = false
			queue_free()
	
	
func show_label() -> void:
	labelTween.interpolate_property(label, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.3,
									Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	labelTween.start()
	label_visible = true
	
	
func hide_label() -> void:
	labelTween.interpolate_property(label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.3,
									Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	labelTween.start()
	label_visible = false


func _on_LabelTween_tween_completed(_object: Object, _key: NodePath) -> void:
	if label_visible:
		hide_label()
	else:
		show_label()


func _on_Shop_pressed() -> void:
	is_shop_opened = true


func _on_shopUI_closed() -> void:
	is_shop_opened = false
