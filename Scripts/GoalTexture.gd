extends VBoxContainer

var current_number: int = 0
var max_value: int = 0
enum {RED, BLUE, GREEN, YELLOW, ORANGE}
var goal_value: String = ""
var goal_texture: Texture = null

onready var textureRect: TextureRect = $TextureRect
onready var goal_label: Label = $Label

func set_goal_values(new_max: int, new_texture: Texture, new_value: String) -> void:
	max_value = new_max
	textureRect.texture = new_texture
	goal_value = new_value
	goal_label.text = str(current_number) + "/" + str(max_value)
	
	
func update_goal_values(goal_type: String) -> void:
	if goal_type == goal_value:
		current_number += 1
		if current_number <= max_value:
			goal_label.text = str(current_number) + "/" + str(max_value)

