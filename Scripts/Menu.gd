extends Node2D

var label_visible: bool = true

onready var cloudTimer: Timer = get_node("CloudTimer")
onready var shipTimer: Timer = get_node("ShipTimer")
onready var birdTimer: Timer = get_node("BirdTimer")
onready var ySortContainer: YSort = get_node("YSort")
onready var label: Label = get_node("VBoxContainer/Label")
onready var labelTween: Tween = get_node("VBoxContainer/Label/LabelTween")

func _ready() -> void:
	randomize()
	
	hide_label()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_touch"):
		SceneTransistor.change_scene("res://Scenes/Map.tscn")


func _on_CloudTimer_timeout() -> void:
	var cloud_path: PackedScene = preload("res://Scenes/Cloud.tscn")
	var cloud: Sprite = cloud_path.instance()
	add_child(cloud)
	
	cloudTimer.wait_time = rand_range(0, 6)


func _on_ShipTimer_timeout() -> void:
	var ship_path: PackedScene = preload("res://Scenes/Ship.tscn")
	var ship: Sprite = ship_path.instance()
	ySortContainer.add_child(ship)
	
	shipTimer.wait_time = rand_range(1, 10)
	
	
func _on_BirdTimer_timeout() -> void:
	var bird_path: PackedScene = preload("res://Scenes/Bird.tscn")
	var bird: AnimatedSprite = bird_path.instance()
	add_child(bird)
	
	birdTimer.wait_time = rand_range(0.5, 5)
	
	
func show_label() -> void:
	labelTween.interpolate_property(label, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.3,
									Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	labelTween.start()
	label_visible = true
	
	
func hide_label() -> void:
	labelTween.interpolate_property(label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.3,
									Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	labelTween.start()
	label_visible = false


func _on_LabelTween_tween_completed(_object: Object, _key: NodePath) -> void:
	if label_visible:
		hide_label()
	else:
		show_label()
