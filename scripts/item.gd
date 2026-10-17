class_name Item extends Area2D

@export var item_id : String = ""
@export var item_value : int = 20

@onready var sprite: Sprite2D = $Sprite2D

func hide_item() -> void:
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func show_item() -> void:
	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
