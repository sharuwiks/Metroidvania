extends CharacterStateMachine

class_name PlayerStateMachine

@onready var idle_state : State = $Idle
@onready var move_state : State = $Move
@onready var jump_state : State = $Jump
@onready var fall_state : State = $Fall
@onready var wall_slide_state : State = $WallSlide
@onready var dash_state : State = $Dash
@onready var hit_state : State = $Hit
@onready var death_state : State = $Death
@onready var attack_state : State = $Attack
