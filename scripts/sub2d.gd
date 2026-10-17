extends CharacterBody2D

@export var coins : int = 0

@export var thrust_speed: float = 1200.0
@export var max_speed: float = 400.0
@export var friction: float = 0.95

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var grab_area: Area2D = $flipnode/GrabArea
@onready var grab_pin: Marker2D = $flipnode/GrabPin
@onready var flipnode: Marker2D = $flipnode
@onready var claw_anim: AnimationPlayer = $AnimationPlayer
@onready var coinlabel: Label = $Control/Coinlabel

var nearby_items: Array[Area2D] = []
var grabbed_item: Area2D = null
var is_animating: bool = false

func _ready() -> void:
	grab_area.area_entered.connect(_on_grab_area_entered)
	grab_area.area_exited.connect(_on_grab_area_exited)

	for child in grab_pin.get_children():
		child.visible = false

func _physics_process(delta: float) -> void:
	coinlabel.text = "Coins: " + str(coins)
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("left", "right")
	input_vector.y = Input.get_axis("up", "down")

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity += input_vector * thrust_speed * delta
		velocity = velocity.limit_length(max_speed)

		if not is_animating:
			if input_vector.x > 0:
				sprite.flip_h = false
				flipnode.scale.x = 1
			elif input_vector.x < 0:
				sprite.flip_h = true
				flipnode.scale.x = -1
	else:
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - pow(friction, delta * 60))

	if Input.is_action_just_pressed("grab"):
		_toggle_grab()

	move_and_slide()

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
