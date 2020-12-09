extends Node2D

signal remove_lock(lock_position)
signal break_lock(value)

var lock_pieces: Array = []
	
func _on_Grid_create_obstacle_array(width: int, height: int):
	lock_pieces = Utils.create_array(width, height)


func _on_Grid_create_lock(lock_position: Vector2):
	var lock: PackedScene = preload("res://Scenes/Obstacles/Lock.tscn")
	var Lock: Sprite = lock.instance()
	add_child(Lock)
	Lock.position = Utils.grid_to_pixel(lock_position.x, lock_position.y)
	lock_pieces[lock_position.x][lock_position.y] = Lock


func _on_Grid_damage_lock(lock_position: Vector2):
	if lock_pieces.size() != 0:
		var lock_piece: Sprite = lock_pieces[lock_position.x][lock_position.y]
		if lock_piece != null:
			lock_piece.take_damage(1)
			if lock_piece.hp <= 0:
				emit_signal("remove_lock", lock_position)
				emit_signal("break_lock", "lock")
