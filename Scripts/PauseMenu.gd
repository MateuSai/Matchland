extends CanvasLayer

var pause: bool = false

onready var panel: Panel = $Panel
onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func change_pause_state() -> void:
	pause = not pause
	get_tree().paused = pause
	panel.visible = pause


func _on_ResumeButton_pressed() -> void:
	animationPlayer.play_backwards("slide_in")
	change_pause_state()


func _on_RetartButton_pressed() -> void:
	change_pause_state()
	animationPlayer.play_backwards("slide_in")
	yield(animationPlayer, "animation_finished")
	get_parent().clean_and_change_scene("res://Scenes/Levels/" + get_parent().name + ".tscn")


func _on_QuitButton_pressed() -> void:
	var map_path: String = "res://Scenes/Map.tscn"
	change_pause_state()
	animationPlayer.play_backwards("slide_in")
	yield(animationPlayer, "animation_finished")
	get_parent().clean_and_change_scene(map_path)


func _on_UI_pause_game() -> void:
	animationPlayer.play("slide_in")
	change_pause_state()
