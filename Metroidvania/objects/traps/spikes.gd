extends Node2D

@export var damage : float = 10.0

func _on_spike_hitbox_body_entered(body):
	if body is Player:
		for child in body.get_children():
			if child is Damageable:
				#Get direction from sword to body
				var direction_to_damageable = (body.global_position - global_position)
				var direction_sign = sign(direction_to_damageable.x)
				child.hit(damage, direction_to_damageable.normalized())
