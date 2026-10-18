extends CharacterBody2D

@export var coins : int = 0

@export var thrust_speed: float = 1200.0
@export var max_speed: float = 400.0
@export var friction: float = 0.95

@export var depth_colors: Array[DepthColorPoint] = []
@export var color_transition_speed: float = 2.0
@export var surface_y: float = 0.0

@export var motor_volume_db: float = 0.0
@export var motor_silent_db: float = -40.0
@export var volume_fade_speed: float = 5.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var grab_area: Area2D = $flipnode/GrabArea
@onready var grab_pin: Marker2D = $flipnode/GrabPin
@onready var flipnode: Marker2D = $flipnode
@onready var claw_anim: AnimationPlayer = $AnimationPlayer
@onready var coinlabel: Label = %Coinlabel
@onready var colli: CollisionShape2D = $CollisionShape2D
@onready var detect_area: Area2D = $DetectArea
@onready var controls_info: TextureRect = %ControlsInfo
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var motor_noise: AudioStreamPlayer = $MotorNoise

var nearby_items: Array[Area2D] = []
var grabbed_item: Area2D = null
var is_animating: bool = false

var items_in_detect_range: Array[Area2D] = []

var _sorted_depth_colors: Array[DepthColorPoint] = []

func _ready() -> void:
	grab_area.area_entered.connect(_on_grab_area_entered)
	grab_area.area_exited.connect(_on_grab_area_exited)

	detect_area.area_entered.connect(_on_detect_area_entered)
	detect_area.area_exited.connect(_on_detect_area_exited)

	for child in grab_pin.get_children():
		child.visible = false

	_sorted_depth_colors = depth_colors.duplicate()
	_sorted_depth_colors.sort_custom(func(a, b): return a.depth < b.depth)

	await get_tree().create_timer(25).timeout
	controls_info.visible = false

func _physics_process(delta: float) -> void:
	coinlabel.text = "Coins: " + str(coins)
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("left", "right")
	input_vector.y = Input.get_axis("up", "down")

	if not is_animating:
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()
			velocity += input_vector * thrust_speed * delta
			velocity = velocity.limit_length(max_speed)

			if input_vector.x > 0:
				sprite.flip_h = false
				flipnode.scale.x = 1
				colli.position.x = -8
			elif input_vector.x < 0:
				sprite.flip_h = true
				flipnode.scale.x = -1
				colli.position.x = 8
		else:
			velocity = velocity.lerp(Vector2.ZERO, 1.0 - pow(friction, delta * 60))

	if Input.is_action_just_pressed("grab"):
		_toggle_grab()

	if Input.is_action_just_pressed("horn"):
		_trigger_horn()

	_update_depth_color(delta)

	move_and_slide()
	_update_motor_sound(delta)

func _get_current_depth() -> float:
	return max(0.0, global_position.y - surface_y)

func _get_target_color_for_depth(depth: float) -> Color:
	if _sorted_depth_colors.is_empty():
		return Color.WHITE

	if _sorted_depth_colors.size() == 1:
		return _sorted_depth_colors[0].color

	if depth <= _sorted_depth_colors[0].depth:
		return _sorted_depth_colors[0].color

	if depth >= _sorted_depth_colors[-1].depth:
		return _sorted_depth_colors[-1].color

	for i in range(_sorted_depth_colors.size() - 1):
		var a = _sorted_depth_colors[i]
		var b = _sorted_depth_colors[i + 1]
		if depth >= a.depth and depth <= b.depth:
			var t = inverse_lerp(a.depth, b.depth, depth)
			return a.color.lerp(b.color, t)

	return _sorted_depth_colors[-1].color

func _update_depth_color(delta: float) -> void:
	if not canvas_modulate or _sorted_depth_colors.is_empty():
		return

	var target_color = _get_target_color_for_depth(_get_current_depth())
	canvas_modulate.color = canvas_modulate.color.lerp(
		target_color,
		clamp(delta * color_transition_speed, 0.0, 1.0)
	)

func _toggle_grab() -> void:
	if is_animating:
		return

	if grabbed_item:
		_release_item()
	elif nearby_items.size() > 0:
		_grab_item(nearby_items[0])

func _grab_item(item: Area2D) -> void:
	is_animating = true
	claw_anim.play("pickup")
	await claw_anim.animation_finished
	is_animating = false

	grabbed_item = item
	nearby_items.erase(item)
	item.hide_item()

	for child in grab_pin.get_children():
		child.visible = (child.name == item.item_id)

func _release_item() -> void:
	if not grabbed_item:
		return

	is_animating = true
	claw_anim.play("drop")
	await claw_anim.animation_finished
	is_animating = false

	grabbed_item.global_position = grab_pin.global_position
	grabbed_item.show_item()
	grabbed_item = null

	for child in grab_pin.get_children():
		child.visible = false

func _on_grab_area_entered(area: Area2D) -> void:
	if area.has_method("hide_item") and area != grabbed_item:
		nearby_items.append(area)

func _on_grab_area_exited(area: Area2D) -> void:
	nearby_items.erase(area)

func sell_grabbed_item() -> void:
	if not grabbed_item or is_animating:
		return

	is_animating = true
	claw_anim.play("drop")
	await claw_anim.animation_finished
	is_animating = false

	coins += grabbed_item.item_value
	grabbed_item.queue_free()
	grabbed_item = null

	for child in grab_pin.get_children():
		child.visible = false

func _on_detect_area_entered(area: Area2D) -> void:
	if area is Item and not items_in_detect_range.has(area):
		items_in_detect_range.append(area)

func _on_detect_area_exited(area: Area2D) -> void:
	items_in_detect_range.erase(area)

func _trigger_horn() -> void:
	for item in items_in_detect_range.duplicate():
		if is_instance_valid(item) and item.has_method("reveal"):
			item.reveal()
		else:
			items_in_detect_range.erase(item)

func _update_motor_sound(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)
	var is_thrusting = input_vector.length() > 0

	if not motor_noise.playing:
		motor_noise.play(motor_noise.get_playback_position())

	var target_db = motor_volume_db if is_thrusting else motor_silent_db
	motor_noise.volume_db = lerp(motor_noise.volume_db, target_db, delta * volume_fade_speed)
