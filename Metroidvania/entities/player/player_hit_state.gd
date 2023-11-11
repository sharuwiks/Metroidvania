extends State

@export var damageable : Damageable


@export var knockback_speed : float = 100.0

func _ready():
	damageable.connect("on_hit", _on_damageable_hit)

func on_enter():
	await get_tree().create_timer(1).timeout
	if character.is_on_floor():
		next_state = state_machine.idle_state
	else:
		next_state = state_machine.fall_state
	
func _on_damageable_hit(node : Node, damage_amount : int, knockback_direction : Vector2):
	if damageable.health > 0:
		character.velocity = knockback_speed * knockback_direction
		emit_signal("interrupt_state", self)
	else:
		emit_signal("interrupt_state", state_machine.death_state)

func on_exit():
	pass
