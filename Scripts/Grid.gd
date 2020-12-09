extends Node2D

const PIECE_PATH: PackedScene = preload("res://Scenes/Piece.tscn")
const DIRECTIONS: Array = [Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN]

# Particles effects
enum {EXPLOSION, BOMB_EXPLOSION, COLOR_BOMB_EXPLOSION, HAMMER_EXPLOSION, BOMB_POWERUP, HORIZONTAL_BOMB,
	  VERTICAL_BOMB}
const EFFECTS: Array = [
	preload("res://Scenes/Particles/Explosion.tscn"),
	preload("res://Scenes/Particles/BombExplosion.tscn"),
	preload("res://Scenes/Particles/ColorBombParticles.tscn"),
	preload("res://Scenes/Particles/HammerParticles.tscn"), 
	preload("res://Scenes/Particles/BombPowerupParticles.tscn"),
	preload("res://Scenes/Particles/LineBombParticles.tscn"),
	preload("res://Scenes/Particles/LineBombParticles.tscn")
]

export(int) var width: int = 0
export(int) var height: int = 0
export(int) var x_start: int = 0
export(int) var y_start: int = 0
export(int) var offset: int = 0
export(int) var y_offset: int = 0
signal grid_defined(x, y, off)
signal create_board(width, height, offset, x_start, y_start)

export(PoolVector2Array) var empty_spaces: PoolVector2Array = []
export(PoolVector2Array) var ice_spaces: PoolVector2Array = []
export(PoolVector2Array) var lock_spaces: PoolVector2Array = []
export(PoolVector2Array) var concrete_spaces: PoolVector2Array = []
export(PoolVector2Array) var vines_spaces: PoolVector2Array = []
var damaged_vines: bool = false

signal create_obstacle_array(width, height)

signal create_ice(ice_position)
signal damage_ice(ice_position)

signal create_lock(lock_position)
signal damage_lock(lock_position)

signal create_vines(vines_position)
signal damage_vines(vines_position)

export(PoolVector3Array) var preset_spaces: PoolVector3Array = []

# Bomb types
enum {NONE, HORIZONTAL, VERTICAL, ADJACENT, COLOR}

var can_move: bool = true setget set_move_state
signal state_changed(can_move)
var item_type: int = 0
var item_selected: bool = false
signal item_used(item)

var pieces_array: Array = []

# Input variables
var first_touch: Vector2 = Vector2.ZERO
var final_touch: Vector2 = Vector2.ZERO
var controlling: bool = false
# Swap pieces
var piece_one: Sprite = null
var piece_two: Sprite = null
var swaped_back: bool = false

signal update_score(score)
var num_pieces_matched_streak: int = 0
var streak: int = 1

signal update_turns()

signal check_goal(goal_type)

export(int) var total_anchors: int = 0
var anchors: int = 0

signal place_camera(new_pos)
signal camera_effect()

# Timers
onready var destroyTimer: Timer = get_node("DestroyTimer")
onready var collapseTimer: Timer = get_node("CollapseTimer")
onready var refillTimer: Timer = get_node("RefillTimer")

func _ready() -> void:
	randomize()
	
	connect("grid_defined", get_node("/root/Utils"), "_on_grid_defined")
	emit_signal("grid_defined", x_start, y_start, offset)
	emit_signal("create_board", width, height, offset, x_start, y_start)
	# Move camera
	var new_pos: Vector2 = Utils.grid_to_pixel(round(width/2.0 - 1), round(height/2.0 - 1))
	emit_signal("place_camera", new_pos)
	
	# Spawn pieces
	pieces_array = Utils.create_array(width, height)
	spawn_preset_pieces()
	spawn_pieces()
	
	# Spawn obstacles
	emit_signal("create_obstacle_array", width, height)
	spawn_obstacles("ice")
	spawn_concrete()
	spawn_obstacles("lock")
	spawn_obstacles("vines")
	spawn_anchors()
	
	if is_deadlocked():
		reorder_grid()
	
	
func _process(_delta: float) -> void:
	if can_move:
		_touch_input()
	elif item_selected:
		_powerup_input()
				
				
func spawn_pieces() -> void:
	for x in width:
		for y in height:
			if pieces_array[x][y] == null and not is_restricted(Vector2(x, y)):
				var piece: Sprite = PIECE_PATH.instance()
				add_child(piece)
				piece.position = Utils.grid_to_pixel(x, y)
				pieces_array[x][y] = piece
				# Avoid matches
				while piece_matches_horizontally(x, y) or piece_matches_vertically(x, y):
					piece.random_color()
				
				
func spawn_preset_pieces() -> void:
	if preset_spaces.size() > 0:
		for i in preset_spaces.size():
			var piece: Sprite = PIECE_PATH.instance()
			add_child(piece)
			piece.position = Utils.grid_to_pixel(preset_spaces[i].x, preset_spaces[i].y)
			piece.change_color(preset_spaces[i].z)
			pieces_array[preset_spaces[i].x][preset_spaces[i].y] = piece
				
				
func spawn_obstacles(obstacle_name: String) -> void:
	for obstacle_position in get(obstacle_name + "_spaces"):
		emit_signal(("create_" + obstacle_name), obstacle_position)
		
		
func spawn_concrete() -> void:
	var concrete_path: PackedScene = preload("res://Scenes/Obstacles/Concrete.tscn")
	if concrete_spaces.size() > 0:
		for i in concrete_spaces:
			var concrete: Sprite = concrete_path.instance()
			concrete.position = Utils.grid_to_pixel(i.x, i.y)
			add_child(concrete)
			pieces_array[i.x][i.y].queue_free()
			pieces_array[i.x][i.y] = concrete
			
			
func spawn_anchors() -> void:
	for i in total_anchors:
		var anchor_path: PackedScene = preload("res://Scenes/Obstacles/Anchor.tscn")
		var anchor: Sprite = anchor_path.instance()
		var rand: int = randi() % width
		while is_restricted(Vector2(rand, 0)) or is_anchor(rand, 0):
			rand = randi() % width
		pieces_array[rand][0].queue_free()
		pieces_array[rand][0] = anchor
		anchor.position = Utils.grid_to_pixel(rand, 0)
		add_child(anchor)
	
	
func spawn_effect(effect: int, column: int, row: int) -> void:
	var particleEffect: Particles2D = EFFECTS[effect].instance()
	particleEffect.position = Utils.grid_to_pixel(column, row)
	if effect == VERTICAL_BOMB:
		particleEffect.rotation_degrees = 90
	add_child(particleEffect)
	
	
func spawn_lightning(initial_position: Vector2, final_position: Vector2) -> void:
	var lightning_path: PackedScene = preload("res://Scenes/Lightning.tscn")
	var lightning: TextureRect = lightning_path.instance()
	lightning.rect_position = initial_position
	var distance: float = abs((initial_position - final_position).length())
	lightning.rect_size.x = distance
	lightning.rect_rotation = rad2deg(get_angle_to(final_position - initial_position))
	add_child(lightning)
	
	
func piece_matches_horizontally(column: int, row: int) -> bool:
	if is_in_grid(Vector2(column, row)):
		if pieces_array[column][row].color != "concrete" and not is_anchor(column, row):
			var color = pieces_array[column][row].color
			# Check if the colors of this piece and the 2 pieces on the left are the same
			if column > 1:
				if is_in_grid(Vector2(column - 1, row)) and is_in_grid(Vector2(column - 2, row)):
					if (pieces_array[column - 1][row].color == color and pieces_array[column - 2][row].color == color):
						return true
	return false
	
	
func piece_matches_vertically(column: int, row: int) -> bool:
	if is_in_grid(Vector2(column, row)):
		if pieces_array[column][row].color != "concrete" and not is_anchor(column, row):
			var color = pieces_array[column][row].color
			# Check if the colors of this piece and the 2 pieces on the up are the same
			if row > 1:
				if is_in_grid(Vector2(column, row - 1)) and is_in_grid(Vector2(column, row - 2)):
					if (pieces_array[column][row - 1].color == color and pieces_array[column][row - 2].color == color):
						return true
	return false
	
	
func _touch_input() -> void:
	# Check input
	var mouse_position: Vector2 = get_global_mouse_position()
	mouse_position = Utils.pixel_to_grid(mouse_position.x, mouse_position.y)
	if Input.is_action_just_pressed("ui_touch") and not is_locked(mouse_position):
		if is_in_grid(mouse_position):
			controlling = true
			first_touch = mouse_position
			
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(mouse_position) and controlling:
			controlling = false
			final_touch = mouse_position
			_touch_difference(first_touch, final_touch)
			
			
func _powerup_input() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	if Input.is_action_just_pressed("ui_touch"):
		var grid_position: Vector2 = Utils.pixel_to_grid(mouse_position.x, mouse_position.y)
		if is_in_grid(grid_position) and not is_locked(grid_position):
			if item_type == 1:
				pieces_array[grid_position.x][grid_position.y].make_bomb(ADJACENT)
				emit_signal("item_used", item_type)
				spawn_effect(BOMB_POWERUP, grid_position.x, grid_position.y)
			elif item_type == 2:
				match_and_check_goal(grid_position.x, grid_position.y)
				emit_signal("item_used", item_type)
				spawn_effect(HAMMER_EXPLOSION, grid_position.x, grid_position.y)
				self.can_move = false
				search_matches()
	
	
func _touch_difference(grid_1: Vector2, grid_2: Vector2) -> void:
	# If is possible, swap the pieces
	var difference: Vector2 = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0 and is_in_grid(grid_1 + Vector2.RIGHT) and not is_locked(grid_1 + Vector2.RIGHT):
			swaped_back = false
			swap_pieces(grid_1.x, grid_1.y, Vector2.RIGHT)
		elif difference.x < 0 and is_in_grid(grid_1 + Vector2.LEFT) and not is_locked(grid_1 + Vector2.LEFT):
			swaped_back = false
			swap_pieces(grid_1.x, grid_1.y, Vector2.LEFT)
	elif abs(difference.x) < abs(difference.y):
		if difference.y > 0 and is_in_grid(grid_1 + Vector2.DOWN) and not is_locked(grid_1 + Vector2.DOWN):
			swaped_back = false
			swap_pieces(grid_1.x, grid_1.y, Vector2.DOWN)
		elif difference.y < 0 and is_in_grid(grid_1 + Vector2.UP) and not is_locked(grid_1 + Vector2.UP):
			swaped_back = false
			swap_pieces(grid_1.x, grid_1.y, Vector2.UP)
			
			
func swap_pieces(column: int, row: int, direction: Vector2) -> void:
	var no_matches: bool = false
	if not swap_and_check_matches(column, row, direction):
		no_matches = true
	# Swap the two pieces
	piece_one = pieces_array[column][row]
	piece_two = pieces_array[column + direction.x][row + direction.y]
	# Move the first piece
	piece_one.move(piece_two.position)
	pieces_array[column + direction.x][row + direction.y] = piece_one
	# Move the second piece
	piece_two.move(Utils.grid_to_pixel(column, row))
	pieces_array[column][row] = piece_two
	
	# If there aren't matches, swap back
	if no_matches and not swaped_back and not will_combine():
			swaped_back = true
			yield(get_tree().create_timer(0.4), "timeout")
			swap_pieces(column + direction.x, row + direction.y, direction * -1)
			return
	elif swaped_back:
		return
	self.can_move = false
	search_matches()
	
	
func will_combine() -> bool:
	if piece_one.bomb_type == COLOR or piece_two.bomb_type == COLOR:
		return true
	elif (piece_one.bomb_type == HORIZONTAL or piece_one.bomb_type == VERTICAL) and (
		piece_two.bomb_type == HORIZONTAL or piece_two.bomb_type == VERTICAL):
			return true
	elif ((piece_one.bomb_type == HORIZONTAL or piece_one.bomb_type == VERTICAL) and
		   piece_two.bomb_type == ADJACENT) or ((piece_two.bomb_type == HORIZONTAL or 
		   piece_two.bomb_type == VERTICAL) and piece_one.bomb_type == ADJACENT):
			return true
	return false
	
	
func search_matches() -> void:
	if piece_one != null and piece_two != null:
		var piece_two_grid: Vector2 = Utils.pixel_to_grid(piece_two.position.x, piece_two.position.y)
		var piece_one_grid: Vector2 = Utils.pixel_to_grid(piece_one.position.x, piece_one.position.y)
		if piece_one.bomb_type == COLOR and piece_two.bomb_type == COLOR:
			match_all_pieces()
		elif piece_one.bomb_type == COLOR:
			if piece_two.color != "concrete" and piece_two.color != "anchor":
				match_pieces_with_color(piece_two_grid.x, piece_two_grid.y, piece_two.color, piece_two.bomb_type)
		elif piece_two.bomb_type == COLOR:
			if piece_one.color != "concrete" and piece_one.color != "anchor":
				match_pieces_with_color(piece_one_grid.x, piece_one_grid.y, piece_one.color, piece_one.bomb_type)
		# + explosion
		if (piece_one.bomb_type == HORIZONTAL or piece_one.bomb_type == VERTICAL) and (
			piece_two.bomb_type == HORIZONTAL or piece_two.bomb_type == VERTICAL):
				match_bomb(piece_two_grid.x, piece_two_grid.y, VERTICAL)
				match_bomb(piece_two_grid.x, piece_two_grid.y, HORIZONTAL)
		# Triple
		if ((piece_one.bomb_type == HORIZONTAL or piece_one.bomb_type == VERTICAL) and
			 piece_two.bomb_type == ADJACENT) or ((piece_two.bomb_type == HORIZONTAL or 
			 piece_two.bomb_type == VERTICAL) and piece_one.bomb_type == ADJACENT):
				if piece_one.bomb_type == ADJACENT:
					if piece_two.bomb_type == HORIZONTAL:
						match_bomb(piece_two_grid.x, piece_two_grid.y - 1, HORIZONTAL)
						match_bomb(piece_two_grid.x, piece_two_grid.y, HORIZONTAL)
						match_bomb(piece_two_grid.x, piece_two_grid.y + 1, HORIZONTAL)
					else:
						match_bomb(piece_two_grid.x - 1, piece_two_grid.y, VERTICAL)
						match_bomb(piece_two_grid.x, piece_two_grid.y, VERTICAL)
						match_bomb(piece_two_grid.x + 1, piece_two_grid.y, VERTICAL)
				else:
					if piece_one.bomb_type == HORIZONTAL:
						match_bomb(piece_two_grid.x, piece_two_grid.y - 1, HORIZONTAL)
						match_bomb(piece_two_grid.x, piece_two_grid.y, HORIZONTAL)
						match_bomb(piece_two_grid.x, piece_two_grid.y + 1, HORIZONTAL)
					else:
						match_bomb(piece_two_grid.x - 1, piece_two_grid.y, VERTICAL)
						match_bomb(piece_two_grid.x, piece_two_grid.y, VERTICAL)
						match_bomb(piece_two_grid.x + 1, piece_two_grid.y, VERTICAL)
			
	for x in width:
		for y in height:
			if pieces_array[x][y] != null:
				# Match and dim the pieces who matches
				if piece_matches_horizontally(x, y):
					match_and_check_goal(x, y)
					match_and_check_goal(x - 1, y)
					match_and_check_goal(x - 2, y)
				if piece_matches_vertically(x, y):
					match_and_check_goal(x, y)
					match_and_check_goal(x, y - 1)
					match_and_check_goal(x, y - 2)
				if y == height - 1 and pieces_array[x][y].color == "anchor":
					match_and_check_goal(x, y)
	# Start the destroy countdown
	destroyTimer.start()
	
	
func match_and_check_goal(column: int, row: int) -> void:
	var piece: Sprite = pieces_array[column][row]
	if not piece.matched:
		piece.match_and_dim()
		match_bomb(column, row, piece.bomb_type)
		if piece.color != "concrete":
			emit_signal("check_goal", piece.color)
		# If there is a obstacle, damage it
		damage_obstacles(column, row)
					
					
func destroy_matched() -> void:
	num_pieces_matched_streak = 0
	# Search bombs in the two pieces that swaped
	if piece_one != null and piece_two != null:
		var piece_one_grid: Vector2 = Utils.pixel_to_grid(piece_one.position.x, piece_one.position.y)
		var piece_two_grid: Vector2 = Utils.pixel_to_grid(piece_two.position.x, piece_two.position.y)
		search_bombs(piece_one_grid.x, piece_one_grid.y)
		piece_one = null
		search_bombs(piece_two_grid.x, piece_two_grid.y)
		piece_two = null
	# Itinerate over the grid
	for x in width:
		for y in height:
			# Destroy matched pieces
			var piece: Sprite = pieces_array[x][y]
			if piece != null:
				if piece.matched:
					num_pieces_matched_streak += 1
					if piece.color == "concrete":
						emit_signal("check_goal", "concrete")
					piece.queue_free()
					spawn_effect(EXPLOSION, x, y)
	# Update the score
	emit_signal("update_score", streak * num_pieces_matched_streak)
	# Shake the camera
	emit_signal("camera_effect")
	# Start the countdown for collapse the columns
	collapseTimer.start()
					
					
func collapse_columns() -> void:
	streak += 1
	for x in width:
		for y in range(height - 1, -1, -1):
			if pieces_array[x][y] == null and not is_restricted(Vector2(x, y)):
				for z in range(y - 1, -1, -1):
					if pieces_array[x][z] != null:
						pieces_array[x][z].move(Utils.grid_to_pixel(x, y))
						pieces_array[x][y] = pieces_array[x][z]
						pieces_array[x][z] = null
						break
	# Start the countdown for refill the columns
	refillTimer.start()
						
						
func refill_columns() -> void:
	for x in width:
		for y in range(height - 1, -1, -1):
			if pieces_array[x][y] == null and not is_restricted(Vector2(x, y)):
				# Add a new piece
				var new_piece: Sprite = PIECE_PATH.instance()
				new_piece.position = Utils.grid_to_pixel(x, -1)
				add_child(new_piece)
				new_piece.move(Utils.grid_to_pixel(x, y))
				pieces_array[x][y] = new_piece
	# If there are matches, search matches again
	for x in width:
		for y in height:
			if piece_matches_horizontally(x, y) or piece_matches_vertically(x, y):
				search_matches()
				return
	# If there aren't more matches
	streak = 1
	if not damaged_vines:
		generate_vines()
	else:
		damaged_vines = false
	self.can_move = true
	emit_signal("update_turns")
	if is_deadlocked():
		reorder_grid()
	
	
func search_bombs(column: int, row: int) -> void:
	var color: String = pieces_array[column][row].color
	var column_matches: int = 1
	var row_matches: int = 1
	if color != "concrete" and color != "anchor":
		# Check matches in all directions
		for direction in DIRECTIONS:
			# Check the matches inside a distance of 1
			if same_color(color, column + direction.x, row + direction.y):
				if direction.x == 0:
					row_matches += 1
				else:
					column_matches += 1
				# If the anterior piece color matches, check the piece in a distance of 2
				if same_color(color, column + 2 * direction.x, row + 2 * direction.y):
					if direction.x == 0:
						row_matches += 1
					else:
						column_matches += 1
		if (column_matches >= 4 or row_matches >= 4) or (column_matches >= 3 and row_matches >= 3):
			num_pieces_matched_streak += 1
			var piece: Sprite = pieces_array[column][row]
			# Avoid destroying the piece
			piece.matched = false
			piece.modulate = Color(1, 1, 1, 1)
			# Create the corresponding bomb
			if column_matches == 5 or row_matches == 5:
				# Make a color bomb
				piece.make_bomb(COLOR)
			elif column_matches >= 3 and row_matches >= 3:
				# Make adjacent bomb
				piece.make_bomb(ADJACENT)
			elif column_matches == 4:
				# Make vertical bomb
				piece.make_bomb(VERTICAL)
			elif row_matches == 4:
				# Make horizontal bomb
				piece.make_bomb(HORIZONTAL)
			
			
func same_color(color: String, column: int, row: int) -> bool:
	if is_in_grid(Vector2(column, row)) and color != "anchor":
		if pieces_array[column][row].color == color:
			return true
	return false
			
			
func match_bomb(column: int, row: int, type: int) -> void:
	# Get the bomb type
	match type:
		NONE:
			return
		ADJACENT:
			# Destroy all pieces inside a distance of 2
			for direction in DIRECTIONS:
				if is_in_grid(Vector2(column, row) + direction):
					match_and_check_goal(column + direction.x, row + direction.y)
				if is_in_grid(Vector2(column, row) +  2 * direction):
					match_and_check_goal(column + 2 * direction.x, row + 2 * direction.y)
			# Corners
			for direction in [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
				if is_in_grid(Vector2(column, row) + direction):
					match_and_check_goal(column + direction.x, row + direction.y)
			spawn_effect(BOMB_EXPLOSION, column, row)
			emit_signal("check_goal", "adjacent")
		HORIZONTAL:
			# Destroy all pieces in the row
			for x in width:
				if pieces_array[x][row] != null:
					match_and_check_goal(x, row)
			spawn_effect(HORIZONTAL_BOMB, column, row)
			emit_signal("check_goal", "horizontal")
			
		VERTICAL:
			# Destroy all pieces in the column
			for y in height:
				if pieces_array[column][y] != null:
					match_and_check_goal(column, y)
			spawn_effect(VERTICAL_BOMB, column, row)
			emit_signal("check_goal", "vertical")
						
						
func match_all_pieces() -> void:
	# Destroy all pieces
	for x in width:
		for y in height:
			if is_in_grid(Vector2(x, y)):
				if not pieces_array[x][y].matched and pieces_array[x][y].color != "anchor":
					match_and_check_goal(x, y)
	spawn_effect(COLOR_BOMB_EXPLOSION, width / 2, height / 2)
	emit_signal("check_goal", "color")
	emit_signal("check_goal", "color")
					
					
func match_pieces_with_color(column: int, row: int, color: String, second_piece_type: int) -> void:
	# Destroy the pieces of the same color
	pieces_array[column][row].matched = true
	for x in width:
		for y in height:
			if is_in_grid(Vector2(x, y)):
				var piece: Sprite = pieces_array[x][y]
				if not piece.matched and piece.color == color:
					if piece.bomb_type == NONE and second_piece_type != NONE:
						piece.make_bomb(second_piece_type)
					match_and_check_goal(x, y)
					spawn_lightning(Utils.grid_to_pixel(column, row), Utils.grid_to_pixel(x, y))
	emit_signal("check_goal", "color")
					
					
func reorder_grid() -> void:
	var pieces_array_clone: Array = unidimensional_pieces_array_copy()
	for x in width:
		for y in height:
			if not is_restricted(Vector2(x, y)) and not is_anchor(x, y) and pieces_array[x][y].color != "concrete":
				var rand: int = randi() % pieces_array_clone.size()
				var piece: Sprite = pieces_array_clone[rand]
				pieces_array[x][y] = piece
				while piece_matches_horizontally(x, y) or piece_matches_vertically(x, y):
					rand = randi() % pieces_array_clone.size()
					piece = pieces_array_clone[rand]
					pieces_array[x][y] = piece
				piece.move(Utils.grid_to_pixel(x, y))
				pieces_array_clone.remove(rand)
	if is_deadlocked():
		reorder_grid()
	else:
		self.can_move = true
	
	
func unidimensional_pieces_array_copy() -> Array:
	var array: Array = []
	for x in width:
		for y in height:
			if not is_restricted(Vector2(x, y)) and not is_anchor(x, y) and pieces_array[x][y].color != "concrete":
				array.append(pieces_array[x][y])
	return array
					
					
func is_deadlocked() -> bool:
	for x in width:
		for y in height:
			# Check swaping left
			if x > 0:
				if pieces_array[x][y] != null and pieces_array[x - 1][y] != null:
					if swap_and_check_matches(x, y, Vector2.LEFT):
						return false
			# Check swaping up
			if y > 0:
				if pieces_array[x][y] != null and pieces_array[x][y - 1] != null:
					if swap_and_check_matches(x, y, Vector2.UP):
						return false
	self.can_move = false
	return true
	
	
func swap_and_check_matches(column: int, row: int, direction: Vector2) -> bool:
	# Store colors
	var color_1: String = pieces_array[column][row].color
	var color_2: String = pieces_array[column + direction.x][row + direction.y].color
	# Invert colors
	pieces_array[column][row].color = color_2
	pieces_array[column + direction.x][row + direction.y].color = color_1
	# Search matches
	for x in width:
		for y in height:
			if piece_matches_horizontally(x, y) or piece_matches_vertically(x, y):
				# Restore initial colors
				pieces_array[column][row].color = color_1
				pieces_array[column + direction.x][row + direction.y].color = color_2
				return true
	# Restore initial colors
	pieces_array[column][row].color = color_1
	pieces_array[column + direction.x][row + direction.y].color = color_2
	return false
		
			
func is_in_grid(location: Vector2) -> bool:
	# Check if the coordinates are in the grid
	if location.x < width and location.x >= 0 and location.y < height and location.y >= 0:
		if pieces_array[location.x][location.y] != null:
			return true
	return false
	
	
func is_restricted(location: Vector2) -> bool:
	if Utils.is_in_array(empty_spaces, location):
		return true
	elif Utils.is_in_array(vines_spaces, location):
		return true
	return false
	
	
func is_locked(location: Vector2) -> bool:
	if Utils.is_in_array(lock_spaces, location):
		return true
	return false
	
	
func is_anchor(column: int, row: int) -> bool:
	if pieces_array[column][row] != null:
		if pieces_array[column][row].color == "anchor":
			return true
	return false
	
	
func damage_obstacles(column: int, row: int) -> void:
	yield(get_tree().create_timer(destroyTimer.wait_time), "timeout")
	
	emit_signal("damage_ice", Vector2(column, row))
	emit_signal("damage_lock", Vector2(column, row))
	if pieces_array[column][row].color != "concrete" and not is_anchor(column, row):
		for direction in DIRECTIONS:
			if is_in_grid(Vector2(column, row) + direction):
				# Damage concrete
				if pieces_array[column + direction.x][row + direction.y].color == "concrete":
					pieces_array[column + direction.x][row + direction.y].match_and_dim()
			# Damage vines
			if column + direction.x >= 0 and column + direction.x < width and row + direction.y >= 0 and row + direction.y < height:
				emit_signal("damage_vines", Vector2(column, row) + direction)
	
	
func set_move_state(value: bool) -> void:
	can_move = value
	emit_signal("state_changed", can_move)
	
	
func _on_LockContainer_remove_lock(location: Vector2) -> void:
	for i in range(lock_spaces.size() - 1, -1, -1):
		if lock_spaces[i] == location:
			lock_spaces.remove(i)
			
			
func generate_vines() -> void:
	if vines_spaces.size() > 0:
		var vines_made: bool = false
		while not vines_made:
			var rand: int = randi() % vines_spaces.size()
			var new_vines_position: Vector2 = find_normal_neighbor(vines_spaces[rand].x, vines_spaces[rand].y)
			if new_vines_position != Vector2(-1, -1):
				pieces_array[new_vines_position.x][new_vines_position.y].queue_free()
				vines_spaces.append(new_vines_position)
				emit_signal("create_vines", new_vines_position)
				vines_made = true
			
			
func find_normal_neighbor(column: int, row: int) -> Vector2:
	for direction in DIRECTIONS:
		if is_in_grid(Vector2(column, row) + direction):
			return Vector2(column, row) + direction
	return Vector2(-1, -1)
	
	
func _on_VinesContainer_remove_vines(location: Vector2) -> void:
	damaged_vines = true
	for i in range(vines_spaces.size() - 1, -1, -1):
		if vines_spaces[i] == location:
			vines_spaces.remove(i)


func _on_Game_game_finished() -> void:
	# Stop game
	can_move = false


func _on_DestroyTimer_timeout() -> void:
	destroy_matched()


func _on_CollapseTimer_timeout() -> void:
	collapse_columns()


func _on_RefillTimer_timeout() -> void:
	refill_columns()


func _on_PowerupsTab_item_selected(item: int) -> void:
	item_type = item
	if item > 0:
		can_move = false
		item_selected = true
	else:
		can_move = true
		item_selected = false
