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
	
	handle_sprint(character.inputs.sprint_strength)
	# Handle player movement based on input
	character.handle_velocity(delta, character.inputs.input_direction)
	
	if character.velocity.x == 0:
		next_state = state_machine.idle_state
	if not character.is_on_floor():
		next_state = state_machine.fall_state
	if character.inputs.jump_pressed:
		next_state = state_machine.jump_state
	elif character.inputs.dash_pressed and character.can_dash and not character.has_dashed:
		next_state = state_machine.dash_state
	elif character.inputs.attack_pressed:
		next_state = state_machine.attack_state

## Sets the sprinting variable according to the strength of the sprint input action
func handle_sprint(sprint_strength: float) -> void:
	if sprint_strength != 0 and character.can_sprint:
		character.sprinting = true
	else:
		character.sprinting = false
