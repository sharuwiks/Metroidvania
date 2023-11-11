extends State

func on_enter():
	character.jumping = false
	character.wall_sliding = false
	character.can_jump = true
	character.wall_jump = false
	character.has_double_jumped = false
	character.has_dashed = false

func state_process(delta):
	character.handle_gravity(delta) 
	character.handle_velocity(delta, character.inputs.input_direction)
	
	if character.inputs.input_direction.x != 0:
		next_state = state_machine.move_state
	if not character.is_on_floor() and character.velocity.y > 0:
		next_state = state_machine.fall_state
	if character.inputs.jump_pressed:
		next_state = state_machine.jump_state
	elif character.inputs.dash_pressed and character.can_dash and not character.has_dashed:
		next_state = state_machine.dash_state
	elif character.inputs.attack_pressed:
		next_state = state_machine.attack_state
