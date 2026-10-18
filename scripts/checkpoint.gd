extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not area is Item:
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	if not player.has_method("sell_item"):
		return

	player.call("sell_item", area)
