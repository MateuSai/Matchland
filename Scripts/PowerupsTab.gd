extends CanvasLayer

var active: bool = true
enum {NONE, BOMB, HAMMER}
var item_selected: int = NONE setget set_item

signal item_selected(item)

onready var bombButton: TextureButton = get_node("MarginContainer/TextureRect/BombButton")
onready var hammerButton: TextureButton = get_node("MarginContainer/TextureRect/HammerButton")
onready var animationPlayer: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
	if SaveGame.saved_data.level >= 8:
		animationPlayer.play("slide_in")
		if SaveGame.saved_data.powerups.bombs == 0:
			bombButton.disabled = true
		if SaveGame.saved_data.powerups.hammers == 0:
			hammerButton.disabled = true
	else:
		queue_free()


func _on_BombButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		Input.set_custom_mouse_cursor(preload("res://Art/UI/Bomb Shop Sprite.png"))
		self.item_selected = BOMB
		unpress_button(HAMMER)
	else:
		if item_selected != HAMMER:
			Input.set_custom_mouse_cursor(null)
			self.item_selected = NONE


func _on_HammerButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		Input.set_custom_mouse_cursor(preload("res://Art/UI/Hammer Shop Sprite.png"))
		self.item_selected = HAMMER
		unpress_button(BOMB)
	else:
		if item_selected != BOMB:
			Input.set_custom_mouse_cursor(null)
			self.item_selected = NONE
		
		
func unpress_button(type: int) -> void:
	if type == BOMB:
		bombButton.pressed = false
		bombButton.modulate = bombButton.TRANSPARENT_COLOR
	elif type == HAMMER:
		hammerButton.pressed = false
		hammerButton.modulate = hammerButton.TRANSPARENT_COLOR
		
		
func set_item(value: int) -> void:
	item_selected = value
	emit_signal("item_selected", item_selected)


func _on_Grid_state_changed(can_move: bool) -> void:
	if can_move and not active:
		active = true
		animationPlayer.play("slide_in")
	elif not can_move and active:
		active = false
		animationPlayer.play_backwards("slide_in")


func _on_Grid_item_used(item: int) -> void:
	Input.set_custom_mouse_cursor(null)
	self.item_selected = NONE
	unpress_button(BOMB)
	unpress_button(HAMMER)
	
	if item == BOMB:
		SaveGame.saved_data.powerups.bombs -= 1
		SaveGame.save_data()
		if SaveGame.saved_data.powerups.bombs == 0:
			bombButton.disabled = true
	elif item == HAMMER:
		SaveGame.saved_data.powerups.hammers -= 1
		SaveGame.save_data()
		if SaveGame.saved_data.powerups.hammers == 0:
			hammerButton.disabled = true


func _on_Game_game_finished() -> void:
	queue_free()
