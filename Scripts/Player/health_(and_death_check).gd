extends Node
class_name Health

signal changed(current: float, max_value: float)
signal depleted

@export var max_health: float = 100.0
@export var respawn_position: Vector3 = Vector3.ZERO

var current_health: float = max_health
var _is_dead: bool = false

@export var player: CharacterBody3D = get_parent()
@onready var stamina: Stamina = get_node("../Stamina")


func _ready() -> void:
	current_health = max_health
	_is_dead = false
	emit_signal("changed", current_health, max_health)

#Dubugging death 
func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		take_damage(28)

func can_take_damage(amount: float) -> bool:
	return not _is_dead and amount > 0.0


func take_damage(amount: float) -> bool:
	if not can_take_damage(amount):
		return false

	current_health = max(0.0, current_health - amount)
	emit_signal("changed", current_health, max_health)

	if current_health <= 0.0:
		_is_dead = true
		emit_signal("depleted")
		death()

	return true


func heal(amount: float) -> void:
	if amount <= 0.0 or _is_dead:
		return

	current_health = min(max_health, current_health + amount)
	emit_signal("changed", current_health, max_health)


func restore(amount: float) -> void:
	_is_dead = false
	current_health = min(max_health, current_health + amount)
	emit_signal("changed", current_health, max_health)


func reset() -> void:
	_is_dead = false
	current_health = max_health
	emit_signal("changed", current_health, max_health)


func death() -> void:
	if stamina != null:
		stamina.restore(stamina.max_stamina)

	reset()
	player.global_position = respawn_position
	player.velocity = Vector3.ZERO
