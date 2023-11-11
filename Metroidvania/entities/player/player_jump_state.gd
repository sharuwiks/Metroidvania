extends State

func on_enter():
	apply_jump(character.inputs.input_direction)
	

func state_process(delta):
	# Handle player movement based on input
	character.handle_velocity(delta, character.inputs.input_direction)
	if character.velocity.y > 0:
		next_state = state_machine.fall_state
	elif character.inputs.jump_strength == 0 and character.velocity.y < 0:
		cancel_jump(delta)
	elif character.inputs.dash_pressed and character.can_dash:
		next_state = state_machine.dash_state

	character.handle_gravity(delta) 

func on_exit():
	character.jumping = false

## If jump is released before reaching the top of the jump, the jump is cancelled using the [param JUMP_CANCEL_FORCE] and delta
func cancel_jump(delta: float) -> void:
	next_state = state_machine.fall_state
	character.velocity.y -= character.JUMP_CANCEL_FORCE * sign(character.velocity.y) * delta

## Applies a jump force to the character in the specified direction, defaults to [param JUMP_FORCE] and [param JUMP_DIRECTIONS.UP]
## but can be passed a new force and direction
func apply_jump(move_direction: Vector2, jump_force: float = character.JUMP_FORCE, jump_direction: int = character.JUMP_DIRECTIONS.UP)-> void:
	character.can_jump = false
	character.should_jump = false
	character.jumping = true

	if (character.wall_jump):
		# Jump away from the direction the character is currently facing
		character.velocity.x += jump_force * -move_direction.x
		character.wall_jump = false
		character.velocity.y = 0

	character.velocity.y += jump_force * jump_direction
