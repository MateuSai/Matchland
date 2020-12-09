extends Node2D

signal remove_concrete(concrete_position)

var concrete_pieces: Array = []
	
func _on_Grid_create_obstacle_array(width: int, height: int) -> void:
	concrete_pieces = Utils.create_array(width, height)


func _on_Grid_create_concrete(concrete_position: Vector2):
	var concrete: PackedScene = preload("res://Scenes/Obstacles/Concrete.tscn")
	var Concrete: Sprite = concrete.instance()
	add_child(Concrete)
	Concrete.position = Utils.grid_to_pixel(concrete_position.x, concrete_position.y)
	concrete_pieces[concrete_position.x][concrete_position.y] = Concrete


func _on_Grid_damage_concrete(concrete_position: Vector2):
	if concrete_pieces.size() != 0:
		var concrete_piece: Sprite = concrete_pieces[concrete_position.x][concrete_position.y]
		if concrete_piece != null:
			concrete_piece.take_damage(1)
			if concrete_piece.hp <= 0:
				emit_signal("remove_concrete", concrete_position)
