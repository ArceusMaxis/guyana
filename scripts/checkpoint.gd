extends Area2D

var nearby_items: Array[Area2D] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if area is Item:
		nearby_items.append(area)
		_sell_item(area)

func _on_area_exited(area: Area2D) -> void:
	nearby_items.erase(area)

func _sell_item(item: Item) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	player.coins += item.item_value
	nearby_items.erase(item)
	item.queue_free()
