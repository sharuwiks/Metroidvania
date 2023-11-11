extends Node

class_name Damageable

signal on_hit(node : Node, damage_taken : int, knockback_direction : Vector2)

@export var max_health : float = 100.0
@export var health : float = 100.0 :
	get:
		return health
	set(value):
		health = value

@export var character : CharacterBody2D
@export var dead_animation : String = "death"

func hit(damage : int, knockback_direction : Vector2):
	if not character.i_frames:
		health -= damage
		emit_signal("on_hit", get_parent(), damage, knockback_direction)
