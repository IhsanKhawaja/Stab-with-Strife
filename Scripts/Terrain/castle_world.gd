extends Node3D

@export var seed := 0
@export var room : PackedScene
@export var roomCount := 15

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	if seed == 0:
		rng.randomize()
		seed = rng.seed
	else:
		rng.seed = seed
	
	generate()

func generate():
	for i in roomCount:
		var newRoom := room.instantiate()
		add_child(newRoom)
		newRoom.seed = seed
		newRoom.generate()
