extends CharacterBody3D


var Health = 100
const SPEED = 3.0
const JUMP_VELOCITY = 4
var push_force = 2.0
var OnLadder = false
var Reading = false
var Holding = false
var HoldObj = null
var JustDropped = false
var JustRead = false
var TEMPERATURE = -1
var ALIVE = true
var Walking = false

func _input(event): # Checks for input
	if event is InputEventMouseMotion: # Checks if the input is the mouse moving
		rotate(Vector3.UP, -event.relative.x * 0.002) # Rotates the player horizontally with the mouse

func _physics_process(delta: float) -> void:
	JustDropped = false
	JustRead = false
	if Holding == true:
		if HoldObj == null:
			Holding = false
			HoldObj = null
			JustDropped = true
	if Holding == true:
		HoldObj.global_position = $Camera3D.global_position - 1*$Camera3D.get_global_transform().basis.z
		HoldObj.linear_velocity = Vector3(0,-1,0)
		HoldObj.angular_velocity = Vector3(0,0,0)
		#print(position)
		#print(HoldObj.position)
		#print("t")
		if Input.is_action_just_pressed("Use"):
			Holding = false
			HoldObj = null
			JustDropped = true
	if Reading == true:
		$Camera3D/CanvasLayer/VBoxContainer/NoteLabel.text = "Press E to Discard Note"
		$Camera3D/CanvasLayer/VBoxContainer/NoteLabel.visible = true
		if Input.is_action_just_pressed("Use"):
			Reading = false
			$Camera3D/CanvasLayer/NoteContents.visible = false
			JustRead = true
	if $Camera3D/RayCast3D.is_colliding() and $Camera3D/RayCast3D.get_collider() != null:
		if $Camera3D/RayCast3D.get_collider().is_in_group("Notes"):
			$Camera3D/CanvasLayer/VBoxContainer/NoteLabel.visible = true
			if Reading == false:
				$Camera3D/CanvasLayer/VBoxContainer/NoteLabel.text = "Press E to Read Note"
				if Input.is_action_just_pressed("Use") and JustRead == false:
					Reading = true
					$Camera3D/CanvasLayer/NoteContents.visible = true
					$Camera3D/CanvasLayer/NoteContents/Label.text = $Camera3D/RayCast3D.get_collider().get_meta("Note").replace("\\n","\n")
			#else:
			#	$Camera3D/CanvasLayer/VBoxContainer/NoteLabel.text = "Press E to Discard Note"
			#	if Input.is_action_just_pressed("Use"):
			#		Reading = false
			#		$Camera3D/CanvasLayer/NoteContents.visible = false
		elif Reading == false:
			$Camera3D/CanvasLayer/VBoxContainer/NoteLabel.visible = false
		if $Camera3D/RayCast3D.get_collider().is_in_group("Holdable"):
			if Holding == false:
				$Camera3D/CanvasLayer/VBoxContainer/HoldLabel.text = "Press E to Pick Up Object"
				$Camera3D/CanvasLayer/VBoxContainer/HoldLabel.visible = true
				if Input.is_action_just_pressed("Use") and JustDropped == false:
					HoldObj = $Camera3D/RayCast3D.get_collider()
					Holding = true
			else:
				$Camera3D/CanvasLayer/VBoxContainer/HoldLabel.text = "Press E to Drop Object"
		else:
			$Camera3D/CanvasLayer/VBoxContainer/HoldLabel.visible = false
	else:
		$Camera3D/CanvasLayer/VBoxContainer/HoldLabel.visible = false
		if Reading == false:
			$Camera3D/CanvasLayer/VBoxContainer/NoteLabel.visible = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and ALIVE == true:
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
	if ALIVE == true:
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if (abs(velocity.x) > 0 or abs(velocity.z) > 0) and $FootRay.is_colliding():
		Walking = true
		if $Footsteps.playing != true:
			$Footsteps.play()
	else:
		Walking = false
		$Footsteps.playing = false
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	# await get_tree().create_timer(1).timeout
	

func temperature():
	await get_tree().create_timer(1).timeout
	if TEMPERATURE >= 0:
		if Health < 100:
			Health += 1
	else:
		Health -= (1/3) * (TEMPERATURE * -1)
		if Health <= 0:
			ALIVE = false
		
func ready():
	temperature()
		
		


func _on_footsteps_finished() -> void:
	if Walking == true:
		$Footsteps.play()


func _on_background_sfx_finished() -> void:
	$BackgroundSFX.play()
