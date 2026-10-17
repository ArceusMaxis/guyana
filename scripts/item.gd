class_name Item extends Area2D

@export var item_id : String = ""
@export var item_value : int = 20

@onready var sprite: Sprite2D = $Sprite2D
@onready var reveal_particles: CPUParticles2D = $RevealParticles
@onready var highlight: ColorRect = $Sprite2D/highlight

func hide_item() -> void:
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func show_item() -> void:
	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func reveal() -> void:
	if not is_instance_valid(self):
		return

	if reveal_particles:
		reveal_particles.restart()
		reveal_particles.emitting = true

	if highlight:
		highlight.visible = true
		await get_tree().create_timer(1.5).timeout

		if is_instance_valid(self) and is_instance_valid(highlight):
			highlight.visible = false
