extends CanvasLayer

onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _on_RetryButton_pressed() -> void:
	change_scene("res://Scenes/Levels/" + get_parent().name + ".tscn")


func _on_QuitButton_pressed() -> void:
	var map_path: String = "res://Scenes/Map.tscn"
	change_scene(map_path)


func _on_Game_game_over() -> void:
	animationPlayer.play("slide_in")
	
	
func change_scene(new_scene: String) -> void:
	animationPlayer.play("slide_out")
	yield(animationPlayer, "animation_finished")
	get_parent().clean_and_change_scene(new_scene)
