extends Node
class_name Stamina

signal changed(current: float, max_value: float)
signal depleted

@export var max_stamina: float = 100.0
@export var regen_per_second: float = 20.0
@export var regen_delay: float = 0.5

var current_stamina: float = max_stamina
var _regen_cooldown: float = 0.0

func _ready() -> void:
	current_stamina = max_stamina
	emit_signal("changed", current_stamina, max_stamina)

func _process(delta: float) -> void:
	if _regen_cooldown > 0.0:
		_regen_cooldown -= delta
		return

	if current_stamina < max_stamina:
		current_stamina = min(max_stamina, current_stamina + regen_per_second * delta)
		emit_signal("changed", current_stamina, max_stamina)

func can_spend(cost: float) -> bool:
	return current_stamina >= cost

func try_spend(cost: float) -> bool:
	if not can_spend(cost):
		return false
	
	current_stamina -= cost
	_regen_cooldown = regen_delay
	emit_signal("changed", current_stamina, max_stamina)

	if current_stamina <= 0.0:
		emit_signal("depleted")
	return true

func restore(amount: float) -> void:
	current_stamina = min(max_stamina, current_stamina + amount)
	emit_signal("changed", current_stamina, max_stamina)
