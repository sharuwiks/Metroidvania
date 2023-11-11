extends StaticBody2D

class_name Checkpoint

@onready var interaction_area: InteractionArea = $InteractionArea

var spawn_point = false
var activated = false


func _ready():
	pass
	
func interact(player: Player):
	if not activated:
		activate()
		print("Activated: " + str(GameManager.current_checkpoint.position))
	
func activate():
	## change animation
	GameManager.current_checkpoint = self
	activated = true
