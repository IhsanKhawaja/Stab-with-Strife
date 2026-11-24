extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var parent = body
		if parent and parent.is_in_group("player"):
			var health = parent.get_node("Health (and death)")
			if health:
				health.death()
