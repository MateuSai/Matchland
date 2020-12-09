extends CanvasLayer

var scene: String = ""

onready var animationPlayer: AnimationPlayer = get_node("AnimationPlayer")

func change_scene(new_scene: String) -> void:
	scene = new_scene
	animationPlayer.play("transition_animation")
	
	
func replace_scene() -> void:
	get_tree().change_scene(scene)

