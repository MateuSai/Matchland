extends Particles2D

func _ready() -> void:
	one_shot = true
	emitting = true
	yield(get_tree().create_timer(lifetime + 0.2), "timeout")
	queue_free()
