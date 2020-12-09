extends Control

export(Texture) var goal_texture: Texture
export(int) var max_needed: int
export(String) var goal_value
var number_collected: int = 0
var goal_met: bool = false

onready var sound: AudioStreamPlayer = get_node("AudioStreamPlayer")

func check_goal(goal_type: String) -> void:
	if goal_type == goal_value:
		update_goal()
		
		
func update_goal() -> void:
	if number_collected < max_needed:
		number_collected += 1
		if number_collected == max_needed:
			if not goal_met:
				goal_met = true
				sound.play()

