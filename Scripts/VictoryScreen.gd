extends CanvasLayer

var appeared: bool = false
var particles_spawned: bool = false

onready var UI: TextureRect = get_parent().get_node("CanvasLayer/UI")
onready var coinsWonLabel: Label = get_node("MarginContainer/TextureRect/VBoxContainer/HBoxContainer/CoinsWonLabel")
onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _on_ContinueButton_pressed() -> void:
	var map_path: String = "res://Scenes/Map.tscn"
	animationPlayer.play_backwards("slide_in")
	yield(animationPlayer, "animation_finished")
	get_parent().clean_and_change_scene(map_path)


func _on_Game_game_won(turns_left: int) -> void:
	if not appeared:
		appeared = true
		var coins_won: int = round(UI.total_score / 10) + turns_left * 5
		coinsWonLabel.text = "+" + str(coins_won)
		SaveGame.saved_data.coins += coins_won
		animationPlayer.play("slide_in")
		
		
func spawn_victory_particles() -> void:
	if not particles_spawned:
		var particles_path: PackedScene = preload("res://Scenes/Particles/VictoryExplosion.tscn")
		var amount: int = randi() % 10 + 5
		for i in amount:
			var victoryParticles: Particles2D = particles_path.instance()
			victoryParticles.position = Vector2(rand_range(140, 220), rand_range(60, 120))
			add_child(victoryParticles)
			yield(get_tree().create_timer(rand_range(0.01, 0.1)), "timeout")
		particles_spawned = true
