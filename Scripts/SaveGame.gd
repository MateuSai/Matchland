extends Node

const FILE_PATH: String = "user://game.save"
var saved_data: Dictionary = {
	'level': 1,
	'last_level_completed': false,
	'coins': 0,
	'powerups': {
		'bombs': 0,
		'hammers': 0
	}
}
var level_just_passed: bool = false

func _ready() -> void:
	load_data()


func save_data() -> void:
	var file: File = File.new()
	file.open(FILE_PATH, File.WRITE)
	file.store_var(saved_data)
	file.close()
	
	
func load_data() -> void:
	var file: File = File.new()
	if file.file_exists(FILE_PATH):
		file.open(FILE_PATH, File.READ)
		saved_data = file.get_var()
		file.close()

