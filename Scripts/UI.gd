extends TextureRect

signal pause_game()

var total_score: int = 0
var level_finished: bool = false

onready var levelLabel: Label = get_node("HorizontalContainer/HBoxContainer/HBoxContainer/LevelLabel")
onready var scoreLabel: Label = $HorizontalContainer/HBoxContainer/HBoxContainer/ScoreLabel
onready var counterLabel: Label = $VerticalContainer/VBoxContainer/CounterLabel

onready var goalsContainer: VBoxContainer = $VerticalContainer/VBoxContainer/GoalsContainer

func _ready() -> void:
	scoreLabel.text = str(total_score)
	levelLabel.text = str(get_parent().get_parent().name)


func _on_Grid_update_score(score: int) -> void:
	total_score += score
	scoreLabel.text = str(total_score)


func _on_Grid_check_goal(goal_type: String) -> void:
	for goalTexture in goalsContainer.get_children():
		goalTexture.update_goal_values(goal_type)


func _on_IceContainer_break_ice(value: String) -> void:
	for goalTexture in goalsContainer.get_children():
		goalTexture.update_goal_values(value)


func _on_PauseButton_pressed() -> void:
	if not level_finished:
		emit_signal("pause_game")


func _on_Game_create_goal(max_needed: int, text: Texture, type: String) -> void:
	var goalTexture: PackedScene = preload("res://Scenes/GoalTexture.tscn")
	var GoalTexture: VBoxContainer = goalTexture.instance()
	goalsContainer.add_child(GoalTexture)
	GoalTexture.set_goal_values(max_needed, text, type)


func _on_Game_update_turns(actual_turns: int) -> void:
	counterLabel.text = str(actual_turns)


func _on_LockContainer_break_lock(value: String) -> void:
	for goalTexture in goalsContainer.get_children():
		goalTexture.update_goal_values(value)
