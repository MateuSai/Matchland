extends VBoxContainer

export(String) var item: String = ""
export(int) var item_cost: int = 00

signal item_purchased(item, cost)

var last_label_effect_finished: bool = true

onready var costLabel: Label = get_node("HBoxContainer/HBoxContainer/CenterContainer/Cost")
onready var buyButtoon: TextureButton = get_node("HBoxContainer/BuyButton")
onready var buttonTween: Tween = get_node("HBoxContainer/BuyButton/ButtonTween")
onready var insufficientCoinsLabel: RichTextLabel = get_node("HBoxContainer/BuyButton/InsufficienceCoinsLabel")
onready var labelTween: Tween = get_node("HBoxContainer/BuyButton/LabelTween")
onready var buySound: AudioStreamPlayer = get_node("BuySound")
onready var failedPurchaseSound: AudioStreamPlayer = get_node("FailedPurchaseSound")

func _ready() -> void:
	connect("item_purchased", get_parent().get_parent().get_parent().get_parent().get_node("ItemsTab"), "_on_item_purchased")
	insufficientCoinsLabel.hide()
	costLabel.text = str(item_cost)
	
	
func buy_effect() -> void:
	var particles_path: PackedScene = preload("res://Scenes/Particles/BuyParticles.tscn")
	var particles: Particles2D = particles_path.instance()
	particles.position = Vector2(buyButtoon.rect_size / 2)
	buyButtoon.add_child(particles)
	
	buttonTween.interpolate_property(buyButtoon, "rect_scale", Vector2(0.9, 0.9), Vector2(1, 1), 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	buttonTween.start()
	
	
func insufficient_coins_effect() -> void:
	if last_label_effect_finished:
		last_label_effect_finished = false
		insufficientCoinsLabel.show()
		labelTween.interpolate_property(insufficientCoinsLabel, "rect_scale", Vector2(0.55, 0.55), Vector2(0.6, 0.6),
										0.1, Tween.TRANS_SINE, Tween.EASE_IN)
		labelTween.start()
		
		yield(get_tree().create_timer(1.5), "timeout")
		
		labelTween.interpolate_property(insufficientCoinsLabel, "modulate", Color(0.93, 0.12, 0.12, 1),
										Color(0.93, 0.12, 0.12, 0), 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
		labelTween.start()
		
		yield(labelTween, "tween_all_completed")
		
		insufficientCoinsLabel.hide()
		insufficientCoinsLabel.modulate = Color(0.93, 0.12, 0.12, 1)
		last_label_effect_finished = true


func _on_BuyButton_pressed() -> void:
	if SaveGame.saved_data.coins >= item_cost:
		buy_effect()
		buySound.play()
		emit_signal("item_purchased", item, item_cost)
	else:
		insufficient_coins_effect()
		failedPurchaseSound.play()
