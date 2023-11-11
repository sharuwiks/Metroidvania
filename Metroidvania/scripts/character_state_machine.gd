extends Node

class_name CharacterStateMachine

@export var character : CharacterBody2D
@export var at : AnimationTree
@export var current_state : State

var prev_state : State
var states : Array[State]

func _ready():
	for child in get_children():
		if (child is State):
			states.append(child)
		
			# Set the states up with what they need to function
			child.state_machine = self
			child.character = character
			child.playback = at["parameters/playback"]
			
		else:
			push_warning("Child " + child.name + "is not a State for PlayerStateMachine")

func _physics_process(delta):
	if (current_state.next_state != null):
		switch_states(current_state.next_state)
	
	current_state.state_process(delta)

func check_if_can_move():
	if current_state != null:
		return current_state.can_move

func switch_states(new_state : State):
	if (current_state != null):
		current_state.on_exit()
		current_state.next_state = null
	prev_state = current_state
	current_state = new_state

	current_state.on_enter()

func _input(event : InputEvent):
	current_state.state_input(event)
