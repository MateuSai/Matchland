extends Node2D

var ice_pieces: Array = []
signal break_ice(value)
const VALUE: String = "ice"

func _on_Grid_create_obstacle_array(width: int, height: int) -> void:
	ice_pieces = Utils.create_array(width, height)
	

func _on_Grid_create_ice(ice_position: Vector2) -> void:
	var ice: PackedScene = preload("res://Scenes/Obstacles/IceBlock.tscn")
	var Ice: Sprite = ice.instance()
	add_child(Ice)
	Ice.position = Utils.grid_to_pixel(ice_position.x, ice_position.y)
	ice_pieces[ice_position.x][ice_position.y] = Ice


func _on_Grid_damage_ice(ice_position: Vector2) -> void:
	if ice_pieces.size() != 0:
		var ice_piece: Sprite = ice_pieces[ice_position.x][ice_position.y]
		if ice_piece != null:
			ice_piece.take_damage(1)
			if ice_piece.hp == 0:
				emit_signal("break_ice", VALUE)
