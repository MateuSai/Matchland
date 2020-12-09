extends Node

const CastleDB = preload("res://addons/thejustinwalsh.castledb/castledb_types.gd")

class Levels:

	const level_1 := "level_1"
	const level_2 := "level_2"
	const level_3 := "level_3"
	const level_4 := "level_4"
	const level_5 := "level_5"
	const level_6 := "level_6"
	const level_7 := "level_7"
	const level_8 := "level_8"
	const level_9 := "level_9"
	const level_10 := "level_10"
	const level_11 := "level_11"
	const level_12 := "level_12"
	const level_13 := "level_13"
	const level_14 := "level_14"
	const level_15 := "level_15"
	const level_16 := "level_16"
	const level_17 := "level_17"
	const level_18 := "level_18"
	const level_19 := "level_19"
	const level_20 := "level_20"

	class LevelsRow:
		var num_level := ""
		var map_position_x := 0
		var map_position_y := 0
		var path_offset := 0
		
		func _init(num_level = "", map_position_x = 0, map_position_y = 0, path_offset = 0):
			self.num_level = num_level
			self.map_position_x = map_position_x
			self.map_position_y = map_position_y
			self.path_offset = path_offset
	
	var all = [LevelsRow.new(level_1, 78, 24, 0), LevelsRow.new(level_2, 129, 9, 43), LevelsRow.new(level_3, 135, 65, 89), LevelsRow.new(level_4, 62, 79, 139), LevelsRow.new(level_5, 73, 119, 155), LevelsRow.new(level_6, 134, 101, 196), LevelsRow.new(level_7, 133, 155, 235), LevelsRow.new(level_8, 204, 163, 282), LevelsRow.new(level_9, 157, 110, 335), LevelsRow.new(level_10, 190, 70, 368), LevelsRow.new(level_11, 238, 95, 408), LevelsRow.new(level_12, 266, 34, 458), LevelsRow.new(level_13, 279, 115, 535), LevelsRow.new(level_14, 315, 152, 562), LevelsRow.new(level_15, 348, 107, 598), LevelsRow.new(level_16, 327, 38, 664), LevelsRow.new(level_17, 390, 60, 720), LevelsRow.new(level_18, 424, 93, 758), LevelsRow.new(level_19, 366, 156, 818), LevelsRow.new(level_20, 422, 145, 843)]
	var index = {level_1: 0, level_2: 1, level_3: 2, level_4: 3, level_5: 4, level_6: 5, level_7: 6, level_8: 7, level_9: 8, level_10: 9, level_11: 10, level_12: 11, level_13: 12, level_14: 13, level_15: 14, level_16: 15, level_17: 16, level_18: 17, level_19: 18, level_20: 19}
	
	func get(id:String) -> LevelsRow:
		if index.has(id):
			return all[index[id]]
		return null

	func get_index(idx:int) -> LevelsRow:
		if idx < all.size():
			return all[idx]
		return null

var levels := Levels.new()
