extends ScrollContainer

const LEVEL_BUTTON_PATH: PackedScene = preload("res://Scenes/LevelButton.tscn")

signal show_coins_tab()
signal change_ship_path_offset(off)
signal move_ship_to_next_level(offset_position)

onready var levelContainer: Control = get_node("TextureRect/LevelContainer")
onready var shopButton: TextureButton = get_node("TextureRect/Shop")
onready var unlockLevelSound: AudioStreamPlayer = get_parent().get_node("LevelUnlockSound")

func _ready() -> void:
	spawn_level_buttons(SaveGame.saved_data.level)
	if SaveGame.saved_data.level == 20 and SaveGame.level_just_passed and not SaveGame.saved_data.last_level_completed:
		var final_screen_path: PackedScene = preload("res://Scenes/FinalScreen.tscn")
		var finalScreen: CanvasModulate = final_screen_path.instance()
		yield(get_tree().create_timer(0.5), "timeout")
		add_child(finalScreen)
	else:
		initialize()
		
		
func initialize() -> void:
	emit_signal("show_coins_tab")
	if SaveGame.level_just_passed and SaveGame.saved_data.level < 20:
		SaveGame.level_just_passed = false
		SaveGame.saved_data.level += 1
		SaveGame.save_data()
		unlock_new_level(SaveGame.saved_data.level)
	elif SaveGame.level_just_passed and SaveGame.saved_data.level == 20 and not SaveGame.saved_data.last_level_completed:
		SaveGame.level_just_passed = false
		spawn_completed_mark(20)
		SaveGame.saved_data.last_level_completed = true
		SaveGame.save_data()
	else:
		levelContainer.get_child(19).get_node("CompletedMark").visible = true
		
	if SaveGame.saved_data.level >= 8 and not SaveGame.level_just_passed:
		shopButton.disabled = false
		
		
func spawn_advise() -> void:
	var advise_path: PackedScene = preload("res://Scenes/Advertise.tscn")
	var advertise: CanvasModulate = advise_path.instance()
	advertise.shopUI = get_parent().get_node("ShopUI")
	add_child(advertise)
		
	
func spawn_level_buttons(available_levels: int) -> void:
	for i in available_levels:
		var LevelButton: TextureButton = LEVEL_BUTTON_PATH.instance()
		LevelButton.level = i + 1
		if not i == available_levels - 1:
			LevelButton.get_node("CompletedMark").show()
		LevelButton.rect_position.x = Data.levels.get_index(i).map_position_x
		LevelButton.rect_position.y = Data.levels.get_index(i).map_position_y
		levelContainer.add_child(LevelButton)
	emit_signal("change_ship_path_offset", Data.levels.get_index(available_levels - 1).path_offset)
	if available_levels > 12:
		scroll_horizontal = 160
	
	
func unlock_new_level(level: int) -> void:
	spawn_completed_mark(level - 1)
	yield(get_tree().create_timer(4.5), "timeout")
	emit_signal("move_ship_to_next_level", Data.levels.get_index(level - 1).path_offset)
	
	
func spawn_completed_mark(num_level: int) -> void:
	var level: TextureButton = levelContainer.get_child(num_level - 1)
	level.appear_completed_mark()


func _on_Path_reached_next_level() -> void:
	var level: int = SaveGame.saved_data.level
	var LevelButton: TextureButton = LEVEL_BUTTON_PATH.instance()
	LevelButton.level = level
	LevelButton.rect_position.x = Data.levels.get_index(level - 1).map_position_x
	LevelButton.rect_position.y = Data.levels.get_index(level - 1).map_position_y
	levelContainer.add_child(LevelButton)
	LevelButton.appear()
	
	var particles_path: PackedScene = preload("res://Scenes/Particles/LevelSpawnParticles.tscn")
	var particles: Particles2D = particles_path.instance()
	particles.position = LevelButton.rect_position + Vector2(8, 8)
	levelContainer.add_child(particles)
	
	unlockLevelSound.play()
	
	yield(particles, "tree_exited")
	
	if level == 8:
		spawn_advise()
	
	if level >= 8:
		shopButton.disabled = false
