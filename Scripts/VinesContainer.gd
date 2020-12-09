extends Node2D

signal remove_vines(vines_position)

var vines_pieces: Array = []
	
func _on_Grid_create_obstacle_array(width: int, height: int) -> void:
	vines_pieces = Utils.create_array(width, height)


func _on_Grid_create_vines(vines_position: Vector2) -> void:
	var vines: PackedScene = preload("res://Scenes/Obstacles/Vines.tscn")
	var Vines: Sprite = vines.instance()
	add_child(Vines)
	Vines.position = Utils.grid_to_pixel(vines_position.x, vines_position.y)
	vines_pieces[vines_position.x][vines_position.y] = Vines


func _on_Grid_damage_vines(vines_position: Vector2) -> void:
	if vines_pieces.size() != 0:
		var vines_piece: Sprite = vines_pieces[vines_position.x][vines_position.y]
		if vines_piece != null:
			vines_piece.take_damage(1)
			if vines_piece.hp <= 0:
				emit_signal("remove_vines", vines_position)
