extends CanvasLayer

onready var coinsLabel: Label = get_node("TextureRect/HBoxContainer/CoinsContainer/Label")
onready var bombsLabel: Label = get_node("TextureRect/HBoxContainer/BombsContainer/Label")
onready var hammersLabel: Label = get_node("TextureRect/HBoxContainer/HammersContainer/Label")
onready var animationPlayer: AnimationPlayer = get_node("AnimationPlayer")
onready var delayTimer: Timer = get_node("DelayTimer")

func _ready() -> void:
	coinsLabel.text = str(SaveGame.saved_data.coins)
	bombsLabel.text = str(SaveGame.saved_data.powerups.bombs)
	hammersLabel.text = str(SaveGame.saved_data.powerups.hammers)


func _on_Map_show_coins_tab() -> void:
	get_node("DelayTimer").start()


func _on_DelayTimer_timeout() -> void:
	animationPlayer.play("slide_in")
	
	
func _on_item_purchased(item: String, cost: int) -> void:
	var fade_label_path: PackedScene = preload("res://Scenes/FadeLabel.tscn")
	
	SaveGame.saved_data.powerups[item + "s"] += 1
	get(item + "sLabel").text = str(SaveGame.saved_data.powerups[item + "s"])
	var itemFadeLabel: Label = fade_label_path.instance()
	itemFadeLabel.text = "+1"
	get(item + "sLabel").add_child(itemFadeLabel)
	itemFadeLabel.get_node("AnimationPlayer").play("fade_up")
	
	SaveGame.saved_data.coins -= cost
	coinsLabel.text = str(SaveGame.saved_data.coins)
	var coinsFadeLabel: Label = fade_label_path.instance()
	coinsFadeLabel.text = "-" + str(cost)
	coinsLabel.add_child(coinsFadeLabel)
	coinsFadeLabel.get_node("AnimationPlayer").play("fade_down")
