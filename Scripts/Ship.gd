extends Sprite

const SHIPS: Array = [preload("res://Art/Ship.png"), preload("res://Art/Ship 3.png"),
					  preload("res://Art/Ship 2.png")]

var speed: float = 0

func _ready() -> void:
	var rand: int = randi() % SHIPS.size()
	texture = SHIPS[rand]
	if rand == 0 or rand == 1:
		flip_h = true
	
	if randi() % 2 == 1:
		position = Vector2(-80, rand_range(0, 100))
		speed = rand_range(20, 40)
	else:
		position = Vector2(400, rand_range(0, 100))
		speed = -rand_range(20, 40)
		flip_h = not flip_h
		
		
func _physics_process(delta: float) -> void:
	position.x += speed * delta
	
	if position.x < -100 or position.x > 500:
		queue_free()
