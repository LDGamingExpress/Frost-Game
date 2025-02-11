extends Node3D
var Logs = 0
var LogNeed = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Ladder/StaticBody3D/CollisionShape3D.disabled = true
	$Ladder/LadderArea/CollisionShape3D.disabled = true
	$Ladder.visible = false


func _on_build_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Wood") and Logs < LogNeed:
		Logs += 1
		body.queue_free()
		$BuildParticles.restart()
		$Label3D.text = str(LogNeed - Logs)+" Logs Needed\nFor Ladder"
		if Logs >= LogNeed:
			$Label3D.visible = false
			$MeshInstance3D.visible = false
			$Ladder/StaticBody3D/CollisionShape3D.set_deferred("disabled",false)
			$Ladder/LadderArea/CollisionShape3D.set_deferred("disabled",false)
			$Ladder.visible = true
