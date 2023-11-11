class_name Player
extends CharacterBody2D


## The four possible character states and the character's current state
enum {IDLE, WALK, JUMP, FALL, WALL_SLIDE}
## The values for the jump direction, default is UP or -1
enum JUMP_DIRECTIONS {UP = -1, DOWN = 1}


@onready var PLAYER_SPRITE: Sprite2D = $Sprite2D ## The [Sprite2D] of the player character
@onready var ANIMATION_PLAYER: AnimationPlayer =  $AnimationPlayer ## The [AnimationPlayer] of the player character
@onready var ANIMATION_TREE: AnimationTree =  $AnimationTree ## The [AnimationTree] of the player character
@onready var STATE_MACHINE: CharacterStateMachine = $PlayerStateMachine ## The [CharacterStateMachine] of the player character

## Enables/Disables hard movement when using a joystick.  When enabled, slightly moving the joystick
## will only move the character at a percentage of the maximum acceleration and speed instead of the maximum.
@export var JOYSTICK_MOVEMENT := false

## Enable/Disable sprinting
@export var ENABLE_SPRINT := true
## Enable/Disable wall jumping
@export var ENABLE_WALL_JUMPING := true
## Enable/Disable double jumping
@export var ENABLE_DOUBLE_JUMPING := true
## Enable/Disable dashing
@export var ENABLE_DASHING := true

@export_group("Input Map Actions")
# Input Map actions related to each movement direction, jumping, and sprinting.  Set each to their related
# action's name in your Input Mapping or create actions with the default names.
@export var ACTION_UP := "up" ## The input mapping for up
@export var ACTION_DOWN := "down" ## The input mapping for down
@export var ACTION_LEFT := "left" ## The input mapping for left
@export var ACTION_RIGHT := "right" ## The input mapping for right
@export var ACTION_JUMP := "jump" ## The input mapping for jump
@export var ACTION_SPRINT := "sprint" ## The input mapping for sprint
@export var ACTION_DASH := "dash" ## The input mapping for sprint
@export var ACTION_ATTACK := "attack" ## The input mapping for sprint

@export_group("Movement Values")
# The following float values are in px/sec when used in movement calculations with 'delta'
## How fast the character gets to the [param MAX_SPEED] value
@export_range(0, 1000, 0.1) var ACCELERATION: float = 500.0
## The overall cap on the character's speed
@export_range(0, 1000, 0.1) var MAX_SPEED: float = 100.0
## How fast the character's dash is
@export_range(0, 1000, 0.1) var DASH_SPEED: float = 240.0
## How long the character's dash lasts for
@export_range(0, 5, 0.1) var DASH_DURATION: float = 0.2
## Sprint multiplier, multiplies the [param MAX_SPEED] by this value when sprinting
@export_range(0, 10, 0.1) var SPRINT_MULTIPLIER: float = 1.5
## How fast the character's speed goes back to zero when not moving on the ground
@export_range(0, 1000, 0.1) var FRICTION: float = 500.0
## How fast the character's speed goes back to zero when not moving in the air
@export_range(0, 1000, 0.1) var AIR_RESISTENCE: float = 200.0
## The speed of gravity applied to the character
@export_range(0, 1000, 0.1) var GRAVITY: float = 500.0
## The speed of the jump when leaving the ground
@export_range(0, 1000, 0.1) var JUMP_FORCE: float = 200.0
## How fast the character's vertical speed goes back to zero when cancelling a jump
@export_range(0, 1000, 0.1) var JUMP_CANCEL_FORCE: float = 800.0
## The speed the character falls while sliding on a wall. Currently this is only active if wall jumping is active as well.
@export_range(0, 1000, 0.1) var WALL_SLIDE_SPEED: float = 50.0
## How long in seconds after walking off a platform the character can still jump, set this to zero to disable it
@export_range(0, 1, 0.01) var COYOTE_TIMER: float = 0.08
## How long in seconds before landing should the game still accept the jump command, set this to zero to disable it
@export_range(0, 1, 0.01) var JUMP_BUFFER_TIMER: float = 0.1

@export_group("Combat Values")
@export_range(0,100,0.1) var DAMAGE: float = 10.0
@export_range(0,500,0.1) var PARRY_KNOCKBACK : float = 150.0
@export_range(0,500,0.1) var HIT_KNOCKBACK : float = 100.0

## The player is sprinting when [param sprinting] is true
var sprinting := false
## The player can jump when [param can_jump] is true
var can_jump := false
## The player should jump when landing if [param should_jump] is true, this is used for the [param jump_buffering]
var should_jump := false
## The player will execute a wall jump if [param can_wall_jump] is true and the last call of move_and_slide was only colliding with a wall.
var wall_jump := false
## The player is jumping when [param jumping] is true
var jumping := false

## The player is dashing when [param dashing] is true
var dashing := false
## The player is wall sliding when [param wall_sliding] is true
var wall_sliding := false
## The player has double jumped when [param has_double_jumped] is true
var has_double_jumped := false
## The player has dashed when [param has_dashed] is true
var has_dashed := false
## The player is invulnerable when [param i_frames] is true
var i_frames := false


## The player can sprint when [param can_sprint] is true
@onready var can_sprint: bool = ENABLE_SPRINT
## The player can wall jump when [param can_wall_jump] is true
@onready var can_wall_jump: bool = ENABLE_WALL_JUMPING
## The player can wall jump when [param can_double_jump] is true
@onready var can_double_jump: bool = ENABLE_DOUBLE_JUMPING
## The player can dash when [param can_dash] is true
@onready var can_dash: bool = ENABLE_DASHING


# Dictionary to store player inputs
var inputs: Dictionary
var last_direction : Vector2 = Vector2.RIGHT


func _ready():
	ANIMATION_TREE.active = true

func _physics_process(delta: float) -> void:
	physics_tick(delta)


## Overrideable physics process used by the controller that calls whatever functions should be called
## and any logic that needs to be done on the [param _physics_process] tick
func physics_tick(delta: float) -> void:
	inputs = get_inputs()

	manage_animations()

	move_and_slide()

	## Die if falling off the map
	if global_position.y >= 200:
		die()

## Death Management
func die():
	GameManager.respawn_player()

## Interaction Management
func interact(area : InteractionArea):
	if area.get_parent().is_in_group("interactables"):
		if area.get_parent() is Checkpoint:
			emit_signal("rest")
			area.get_parent().interact(self)


## Manages the character's animations based on the current state and [param PLAYER_SPRITE] direction based on
## the current horizontal velocity. The expected default animations are [param Idle], [param Walk], [param Jump], and [param Fall]
func manage_animations() -> void:
	if velocity.x > 0:
		PLAYER_SPRITE.flip_h = false
	elif velocity.x < 0:
		PLAYER_SPRITE.flip_h = true


## Gets the strength and status of the mapped actions
func get_inputs() -> Dictionary:
	return {
		input_direction = get_input_direction(),
		jump_strength = Input.get_action_strength(ACTION_JUMP),
		jump_pressed = Input.is_action_just_pressed(ACTION_JUMP),
		jump_released = Input.is_action_just_released(ACTION_JUMP),
		sprint_strength = Input.get_action_strength(ACTION_SPRINT) if ENABLE_SPRINT else 0.0,
		dash_pressed = Input.is_action_just_pressed(ACTION_DASH),
		attack_pressed = Input.is_action_just_pressed(ACTION_ATTACK),
	}


## Gets the X/Y axis movement direction using the input mappings assigned to the ACTION UP/DOWN/LEFT/RIGHT variables
func get_input_direction() -> Vector2:
	var x_dir: float = Input.get_action_strength(ACTION_RIGHT) - Input.get_action_strength(ACTION_LEFT)
	var y_dir: float = Input.get_action_strength(ACTION_DOWN) - Input.get_action_strength(ACTION_UP)

	return Vector2(x_dir if JOYSTICK_MOVEMENT else sign(x_dir), y_dir if JOYSTICK_MOVEMENT else sign(y_dir))


# ------------------ Movement Logic ---------------------------------
## Takes the delta and applies gravity to the player depending on their state.  This has
## to be handled after the state and animations in the default behaviour to make sure the 
## animations are handled correctly.
func handle_gravity(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	if can_wall_jump and wall_sliding and not jumping:
		velocity.y = clampf(velocity.y, 0.0, WALL_SLIDE_SPEED)



## Takes delta and the current input direction and either applies the movement or applies friction
func handle_velocity(delta: float, input_direction: Vector2 = Vector2.ZERO) -> void:
	if input_direction.x != 0:
		apply_velocity(delta, input_direction)
		last_direction = input_direction.normalized()
	else:
		apply_friction(delta)


## Applies velocity in the current input direction using the [param ACCELERATION], [param MAX_SPEED], and [param SPRINT_MULTIPLIER]
func apply_velocity(delta: float, move_direction: Vector2) -> void:
	var sprint_strength: float = SPRINT_MULTIPLIER if sprinting else 1.0
	velocity.x += move_direction.x * ACCELERATION * delta * (sprint_strength if is_on_floor() else 1.0)
	velocity.x = clamp(velocity.x, -MAX_SPEED * abs(move_direction.x) * sprint_strength, MAX_SPEED * abs(move_direction.x) * sprint_strength)


## Applies friction to the horizontal axis when not moving using the [param FRICTION] and [param AIR_RESISTENCE] values
func apply_friction(delta: float) -> void:
	var fric: float = FRICTION * delta * sign(velocity.x) * -1 if is_on_floor() else AIR_RESISTENCE * delta * sign(velocity.x) * -1
	if abs(velocity.x) <= abs(fric):
		velocity.x = 0
	else:
		velocity.x += fric

##Applies knockback when hit or parrying
func apply_knockback(knockback_direction : Vector2, knockback_force : float):
	velocity = knockback_force * knockback_direction
