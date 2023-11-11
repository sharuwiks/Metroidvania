extends State

@onready var dash_timer : Timer = $DashTimer

var dash_direction : float = 0.0

func on_enter():
	character.dashing = true
	character.has_dashed = true
	dash_timer.start(character.DASH_DURATION)
	if character.inputs.input_direction != Vector2.ZERO:
		dash_direction = character.inputs.input_direction.x
	else:
		dash_direction = character.last_direction.x
	character.velocity.x  = dash_direction * character.DASH_SPEED

func state_process(delta):
	if not character.dashing:
		next_state = state_machine.fall_state


func on_exit():
	character.dashing = false


func _on_dash_timer_timeout():
	character.dashing = false
