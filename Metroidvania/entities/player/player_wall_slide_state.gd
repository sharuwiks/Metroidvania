extends State

func on_enter():
	character.wall_sliding = true

func state_process(delta):
	character.handle_gravity(delta) 
	# Handle player movement based on input
	character.handle_velocity(delta, character.inputs.input_direction)
	
	if character.is_on_floor():
		next_state = state_machine.idle_state
	elif character.inputs.jump_pressed:
		character.wall_jump = true
		next_state = state_machine.jump_state
	elif character.inputs.input_direction.x == 0 or not character.is_on_wall_only():
		next_state = state_machine.fall_state


func on_exit():
	character.wall_sliding = false
