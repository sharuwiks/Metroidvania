extends State

func on_enter():
	if not character.is_on_floor() and character.can_jump:
		coyote_time()

func state_process(delta):
	
	character.handle_velocity(delta, character.inputs.input_direction)

	if character.is_on_floor():
		if character.should_jump:
			next_state = state_machine.jump_state
		else:
			next_state = state_machine.idle_state
	elif character.can_wall_jump and character.is_on_wall_only() and character.inputs.input_direction.x != 0:
		next_state = state_machine.wall_slide_state
	elif character.inputs.jump_pressed and character.can_double_jump and not character.has_double_jumped:
		next_state = state_machine.jump_state
		character.has_double_jumped = true
	elif character.inputs.dash_pressed and character.can_dash:
		next_state = state_machine.dash_state
	elif character.inputs.jump_pressed:
		buffer_jump()
	
	character.handle_gravity(delta) 


func buffer_jump() -> void:
	character.should_jump = true
	await get_tree().create_timer(character.JUMP_BUFFER_TIMER).timeout
	character.should_jump = false


## If the character steps off of a platform, they are given an amount of time in the air to still jump using the [param COYOTE_TIMER] value
func coyote_time() -> void:
	await get_tree().create_timer(character.COYOTE_TIMER).timeout
	character.can_jump = false
