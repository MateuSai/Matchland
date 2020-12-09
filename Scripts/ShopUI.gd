extends CanvasLayer

const FINAL_POSITION: Vector2 = Vector2(80, 38)

signal closed()

var pause: bool = false
var advise_mode: bool = false

onready var panel: Panel = get_node("Panel")
onready var textureRect: TextureRect = get_node("TextureRect")
onready var tween: Tween = get_node("Tween")

onready var shop: TextureButton = get_parent().get_node("Map/TextureRect/Shop")

func change_pause_state() -> void:
	pause = not pause
	get_tree().paused = pause
	panel.visible = pause


func _on_Shop_pressed() -> void:
	if not advise_mode:
		change_pause_state()
	textureRect.show()
	var initial_position: Vector2 = Vector2(shop.rect_global_position.x + shop.rect_size.x / 2,
											shop.rect_global_position.y + shop.rect_size.y / 2)
	tween.interpolate_property(textureRect, "rect_position", initial_position, FINAL_POSITION, 2, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(textureRect, "rect_scale", Vector2(0.05, 0.05), Vector2(1, 1), 2, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	tween.start()
	if not advise_mode:
		shop.disabled = true


func _on_XButton_pressed() -> void:
	var initial_position: Vector2 = Vector2(shop.rect_global_position.x + shop.rect_size.x / 2,
											shop.rect_global_position.y + shop.rect_size.y / 2)
	tween.interpolate_property(textureRect, "rect_position", FINAL_POSITION, initial_position, 2, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.interpolate_property(textureRect, "rect_scale", Vector2(1, 1), Vector2(0.05, 0.05), 2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	textureRect.hide()
	if not advise_mode:
		change_pause_state()
		shop.disabled = false
	else:
		emit_signal("closed")
