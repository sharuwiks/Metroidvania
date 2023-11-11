extends Area2D


func _ready():
	monitoring = false
	visible = false

func _on_area_entered(area):
	var body = area.get_parent()
	var player = self.get_parent()
	#Get direction from character to body
	var direction_to_body = (body.global_position - get_parent().global_position)
	for child in body.get_children():
		if child is Damageable:
			child.hit(player.DAMAGE, direction_to_body.normalized())
	
	if body.is_in_group("parryable"):
		player.apply_knockback(player.inputs.input_direction * (-1), player.PARRY_KNOCKBACK)
		body.parry()

