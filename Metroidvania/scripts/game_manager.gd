extends Node

@onready var player = get_tree().get_first_node_in_group("player")

var current_checkpoint : Checkpoint

func respawn_player():
	if current_checkpoint != null:
		player.position = current_checkpoint.position
