extends CanvasLayer

@onready var stamina_bar = $Control/StaminaBar
@onready var health_bar = $Control/HealthBar
@onready var player: Node = get_node("../Player")
@onready var stamina: Stamina = player.get_node("Stamina")
@onready var health: Health = player.get_node("Health (and death)")

func _ready() -> void:
	stamina.changed.connect(_on_stamina_changed)
	_on_stamina_changed(stamina.current_stamina, stamina.max_stamina)
	health.changed.connect(_on_health_changed)
	_on_health_changed(health.current_health, health.max_health)
	
func _on_stamina_changed(current: float, max_value: float) -> void:
	stamina_bar.max_value = max_value
	stamina_bar.value = current

func _on_health_changed(current: float, max_value: float) -> void:
	health_bar.max_value = max_value
	health_bar.value = current
