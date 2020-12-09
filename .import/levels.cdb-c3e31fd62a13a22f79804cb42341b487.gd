extends Node

const CastleDB = preload("res://addons/thejustinwalsh.castledb/castledb_types.gd")

class Levels:

	const level_1 := "level_1"

	class LevelsRow:
		var num_level := ""
		var map_position_x := 0
		var map_position_y := 0
		
		func _init(num_level = "", map_position_x = 0, map_position_y = 0):
			self.num_level = num_level
			self.map_position_x = map_position_x
			self.map_position_y = map_position_y
	
	var all = [LevelsRow.new(level_1, 78, 24)]
	var index = {level_1: 0}
	
	func get(id:String) -> LevelsRow:
		if index.has(id):
			return all[index[id]]
		return null

	func get_index(idx:int) -> LevelsRow:
		if idx < all.size():
			return all[idx]
		return null

var levels := Levels.new()
