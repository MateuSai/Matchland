extends TileMap

func _on_Grid_create_board(width: int, height: int, offset: int, x_start: int, y_start: int) -> void:
	var initial_x_cell: int = (x_start / (16 + offset))
	var initial_y_cell: int = (y_start / (16 + offset))
	position += Vector2(8.5, 1.5)
	for x in width + 2:
		for y in height + 2:
			set_cell(initial_x_cell + x, initial_y_cell + y, 0)
	update_bitmask_region(Vector2(initial_x_cell, initial_y_cell), Vector2(initial_x_cell + width + 1, initial_y_cell + height + 1))
