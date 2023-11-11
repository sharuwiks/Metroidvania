extends Node

class_name State

@export var can_move : bool = true

var state_machine : CharacterStateMachine
var character : CharacterBody2D
var next_state : State
var playback : AnimationNodeStateMachinePlayback

func on_enter():
	pass

func state_input(event : InputEvent):
	pass

func state_process(delta):
	pass
	
func on_exit():
	pass
