extends Sprite

export(int) var hp: int = 1

func take_damage(damage: int) -> void:
	hp -= damage
	if hp <= 0:
		queue_free()
