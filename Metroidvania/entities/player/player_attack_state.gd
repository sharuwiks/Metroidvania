extends State

@onready var attack_hitbox : Area2D = $"../../AttackHitbox"

func on_enter():
	var attack_direction = character.inputs.input_direction
	attack_hitbox.rotation = attack_direction.angle()
	attack_hitbox.monitoring = true
	attack_hitbox.visible = true
	
	await get_tree().create_timer(0.2).timeout
	
	if character.is_on_floor():
		if character.velocity.x == 0:
			next_state = state_machine.idle_state
		else:
			next_state = state_machine.move_state
	else:
		next_state = state_machine.fall_state
	
func state_process(delta):
	character.handle_velocity(delta, character.inputs.input_direction)
	character.handle_gravity(delta) 

func on_exit():
	attack_hitbox.monitoring = false
	attack_hitbox.visible = false
