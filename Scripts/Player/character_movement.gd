extends CharacterBody3D

@export var SPEED := 8.0
@export var JUMP_VELOCITY := 6.0

@export var max_air_dashes: int = 2
var air_dashes_used: int = 0

@export var dash_distance := 4.0
@export var dash_duration := 0.2
@export var max_dash_vertical_ratio: float = 0.2

var is_dashing := false
var dash_timer := 0.0
var dash_direction := Vector3.ZERO

@export var dash_stamina_cost: float = 25.0
@onready var stamina: Stamina = $Stamina

@export var mouse_sensitivity: float = 0.003
@export var max_look_angle: float = 89.0 # Prevents breaking your neck looking too far up/down

@onready var head: Node3D = $Head

func _ready() -> void:
	# Lock the mouse to the center of the screen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# 1. Rotate the whole player body left and right (Yaw)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# 2. Rotate just the head/camera up and down (Pitch)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		
		# 3. Clamp the vertical look angle so you don't flip upside down
		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-max_look_angle),
			deg_to_rad(max_look_angle)
		)

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Reset air dashes when grounded
	if is_on_floor():
		air_dashes_used = 0
		
	# Handling jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Unbinding the mouse for future purposes
	if Input.is_action_just_pressed("Unhold_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			push_error("Current Mouse Mode not usual")
			
	# Start dash
	if not is_dashing and Input.is_action_just_pressed("Dash"):
		var on_floor := is_on_floor()
		var can_dash := on_floor or air_dashes_used < max_air_dashes
		
		if can_dash:
			var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
			if input_dir != Vector2.ZERO:
				# Spend stamina only when we know dash will happen
				if not stamina.try_spend(dash_stamina_cost):
					move_and_slide()
					return

				var cam_basis := head.global_transform.basis

				# Camera-relative horizontal direction (yaw-based)
				var flat_forward := -cam_basis.z
				flat_forward.y = 0.0
				flat_forward = flat_forward.normalized()

				var flat_right := cam_basis.x
				flat_right.y = 0.0
				flat_right = flat_right.normalized()

				var flat_dash := (flat_right * input_dir.x - flat_forward * input_dir.y).normalized()

				# Optional small pitch influence from camera
				var vertical: float = clamp((-cam_basis.z).y, -max_dash_vertical_ratio, max_dash_vertical_ratio)

				dash_direction = Vector3(flat_dash.x, vertical, flat_dash.z).normalized()
				is_dashing = true
				dash_timer = dash_duration

				# Consume one air dash only if airborne
				if not on_floor:
					air_dashes_used += 1

	# Execute dash
	if is_dashing:
		dash_timer -= delta
		var dash_speed := dash_distance / dash_duration
		velocity = dash_direction * dash_speed

		if dash_timer <= 0.0:
			is_dashing = false
			# optional: kill leftover horizontal momentum after dash
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		# Normal movement ONLY when not dashing
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction != Vector3.ZERO:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			
	move_and_slide()
