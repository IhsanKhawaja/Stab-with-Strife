extends Camera3D

@export var move_speed := 8.0
@export var look_speed := 90.0
@export var max_pitch := 89.0

var yaw := 0.0
var pitch := 0.0


func _ready() -> void:
	print("I Live!")
	yaw = rotation_degrees.y
	pitch = rotation_degrees.x

func _input(event: InputEvent) -> void:
	print(event)

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_A):
		print("A is down (polled)")
	
	var look := Input.get_vector(
		"TESTING-Lookleft", "TESTING-Lookright",
		"TESTING-Lookdown", "TESTING-Lookup")
	yaw -= look.x * look_speed * delta
	pitch += look.y * look_speed * delta
	pitch = clamp(pitch, -max_pitch, max_pitch)
	rotation_degrees = Vector3(pitch, yaw, 0.0)

	var input := Input.get_vector("left", "right", "forward", "backward")
	var vertical := Input.get_axis("down", "up")

	var dir := global_transform.basis * Vector3(input.x, 0.0, input.y)
	dir += Vector3.UP * vertical
	if dir.length() > 1.0:
		dir = dir.normalized()
	
	global_position += dir * move_speed * delta
