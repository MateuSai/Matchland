extends Sprite

const CLOUDS: Array = [preload("res://Art/Cloud.png"), preload("res://Art/Cloud 2.png")]

var speed: float = 0

func _ready() -> void:
	texture = CLOUDS[randi() % CLOUDS.size()]
	
	if randi() % 2 == 1:
		position = Vector2(-80, rand_range(0, 320))
		speed = rand_range(20, 50)
	else:
		position = Vector2(400, rand_range(0, 320))
		speed = -rand_range(20, 50)
		
		
func _physics_process(delta: float) -> void:
	position.x += speed * delta
	
	if position.x < -100 or position.x > 500:
		queue_free()

