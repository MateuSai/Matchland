extends Node

var x_start: int = 0
var y_start: int = 0
var offset: int = 0
	
	
func _on_grid_defined(x: int, y: int, off: int) -> void:
	x_start = x
	y_start = y
	offset = off
	
	
func create_array(width: int, height: int) -> Array:
	var array: Array = []
	array.resize(width)
	for i in array.size():
		array[i] = []
		array[i].resize(height)
	return array
	
	
func is_in_array(array: Array, item) -> bool:
	for i in array.size():
		if array[i] == item:
			return true
	return false
	
	
func add_to_array(array: Array, item) -> Array:
	if not array.has(item):
		array.append(item)
	return array
	
	
func remove_from_array(array: Array, item) -> Array:
	for i in range(array.size() - 1, -1, -1):
		if array[i] == item:
			array.remove(i)
	return array
	

func grid_to_pixel(grid_x: int, grid_y:int) -> Vector2:
	var pixel_x: int = x_start + offset * grid_x
	var pixel_y: int = y_start + offset * grid_y
	return Vector2(pixel_x, pixel_y)
	
	
func pixel_to_grid(pixel_x: float, pixel_y: float) -> Vector2:
	var grid_x: int = round((pixel_x - x_start) / offset)
	var grid_y: int = round((pixel_y - y_start) / offset)
	return Vector2(grid_x, grid_y)
