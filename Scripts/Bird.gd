extends AnimatedSprite

var speed: float = 0

func _ready() -> void:
	if randi() % 2 == 1:
		position = Vector2(-80, rand_range(0, 180))
		speed = rand_range(30, 50)
	else:
		position = Vector2(400, rand_range(0, 180))
		speed = -rand_range(30, 50)
		flip_h = not flip_h
		
		
func _physics_process(delta: float) -> void:
	position.x += speed * delta
	
	if position.x < -100 or position.x > 500:
		queue_free()

