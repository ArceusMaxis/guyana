extends AudioStreamPlayer

func _ready() -> void:
	play_on_timer()

func play_on_timer() -> void:
	var wait_time = randf_range(10.0, 30.0)
	await get_tree().create_timer(wait_time).timeout
	play()
	play_on_timer()
