extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 3.5
var push_force = 2.0
var OnLadder = false

func _input(event): # Checks for input
	if event is InputEventMouseMotion: # Checks if the input is the mouse moving
		rotate(Vector3.UP, -event.relative.x * 0.002) # Rotates the player horizontally with the mouse

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if $Camera3D/RayCast3D.is_colliding():
		if $Camera3D/RayCast3D.get_collider().is_in_group("Notes"):
			$Camera3D/CanvasLayer/NoteLabel.visible = true
		else:
			$Camera3D/CanvasLayer/NoteLabel.visible = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if OnLadder == true:
		if Input.is_action_pressed("Forward"):
			velocity.y = SPEED
		if Input.is_action_pressed("Backward"):
			velocity.y = -SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
