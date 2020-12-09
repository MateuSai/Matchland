extends Node2D

export(int) var turns: int = 10

signal create_goal(max_needed, text, type)
signal update_turns(actual_turns)
signal game_won(turns_left)
signal game_over()
signal game_finished()

var game_won: bool = false
var game_over: bool = false

onready var animationPlayer: AnimationPlayer = get_node("AnimationPlayer")
onready var goalContainer: Control = get_node("GoalContainer")
onready var UI: TextureRect = get_node("CanvasLayer/UI")

func _ready()-> void:
	create_goals()
	emit_signal("update_turns", turns)
	

func create_goals() -> void:
	for goal in goalContainer.get_children():
		emit_signal("create_goal", goal.max_needed, goal.goal_texture, goal.goal_value)


func check_goals(goal_type: String) -> void:
	for goal_node in goalContainer.get_children():
		goal_node.check_goal(goal_type)
		
		
func goals_met() -> bool:
	for goal_node in goalContainer.get_children():
		if not goal_node.goal_met:
			return false
	return true


func _on_Grid_update_turns() -> void:
	turns -= 1
	emit_signal("update_turns", turns)
	# Check game win
	if goals_met() and not game_over:
		game_won = true
		emit_signal("game_won", turns)
		emit_signal("game_finished")
		UI.level_finished = true
		SaveGame.level_just_passed = true
		SaveGame.save_data()
	# Check game over
	if turns <= 0 and not game_won:
		game_over = true
		emit_signal("game_over")
		emit_signal("game_finished")
		UI.level_finished = true
		
		
func clean_and_change_scene(new_scene: String) -> void:
	animationPlayer.play("change_scene")
	yield(animationPlayer, "animation_finished")
	SceneTransistor.change_scene(new_scene)
