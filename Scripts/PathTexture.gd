extends TextureRect

var speed: int = 20
var next_path_offset: int = 0
var signal_emited: bool = true
signal reached_next_level()

onready var pathFollow: PathFollow2D = get_node("ShipPath/PathFollow2D")
onready var ship: AnimatedSprite = get_node("ShipPath/PathFollow2D/Ship")

func _process(delta: float) -> void:
	if pathFollow.offset < next_path_offset:
		pathFollow.offset += 20 * delta
	else:
		if not signal_emited:
			emit_signal("reached_next_level")
			ship.animation = "default"
			signal_emited = true


func _on_Map_change_ship_path_offset(off: int) -> void:
	pathFollow.offset = off


func _on_Map_move_ship_to_next_level(offset_position: int) -> void:
	ship.animation = "moving"
	next_path_offset = offset_position
	signal_emited = false
