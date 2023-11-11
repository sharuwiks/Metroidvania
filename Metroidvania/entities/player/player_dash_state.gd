extends State

@onready var dash_timer : Timer = $DashTimer

var dash_direction : Vector2 = Vector2.ZERO

func on_enter():
	character.dashing = true
	character.has_dashed = true
	dash_timer.start(character.DASH_DURATION)
	if character.inputs.input_direction != Vector2.ZERO:
		dash_direction = character.inputs.input_direction
	else:
		dash_direction = character.last_direction
	character.velocity  = dash_direction.normalized() * character.DASH_SPEED

func state_process(delta):
	if not character.dashing:
		next_state = state_machine.fall_state
	
func on_exit():
	character.dashing = false


func _on_dash_timer_timeout():
	character.dashing = false
