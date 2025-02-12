extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.TEMPERATURE = 30

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.TEMPERATURE = -1
