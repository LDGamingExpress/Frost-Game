extends Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Hides and keeps the mouse centered

func _input(event): # Checks for input
	if event is InputEventMouseMotion: # Checks if the input is the mouse moving
		rotate(Vector3.LEFT, event.relative.y * 0.002) # Rotates the player vertically with the mouse

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
