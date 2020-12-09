extends Sprite

const PIECE_TEXTURE: Array = [
	preload("res://Art/Pieces/Red Piece.png"),
	preload("res://Art/Pieces/Blue Piece.png"),
	preload("res://Art/Pieces/Green Piece.png"),
	preload("res://Art/Pieces/Yellow Piece.png"),
	preload("res://Art/Pieces/Orange Piece.png")
]
const COLORS: Array = ["red", "blue", "green", "yellow", "orange"]
var color: String = ""
var matched: bool = false

enum {NONE, HORIZONTAL, VERTICAL, ADJACENT, COLOR}
const BOMB_TEXTURES: Array = [
	preload("res://Art/Pieces/Horizontal Line.png"),
	preload("res://Art/Pieces/Vertical Line.png"),
	preload("res://Art/Pieces/Bomb.png"),
	preload("res://Art/Pieces/Color Bomb.png")
]
var bomb_type: int = NONE

onready var moveTween: Tween = $MoveTween
onready var bombSprite: Sprite = $BombSprite

func _ready() -> void:
	random_color()
	
	
func move(final_position: Vector2) -> void:
	moveTween.interpolate_property(self, "position", position, final_position, 0.4,
								   Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	moveTween.start()
	
	
func make_bomb(type: int) -> void:
	if type == COLOR:
		color = "color"
	bomb_type = type
	bombSprite.texture = BOMB_TEXTURES[bomb_type - 1]
	modulate = Color(1, 1, 1, 1)
	
	
func match_and_dim() -> void:
	matched = true
	modulate = Color(1, 1, 1, 0.5)
	
	
func change_color(x: int) -> void:
	texture = PIECE_TEXTURE[x]
	color = COLORS[x]
	
	
func random_color() -> void:
	var x: int = randi() % PIECE_TEXTURE.size()
	texture = PIECE_TEXTURE[x]
	color = COLORS[x]
