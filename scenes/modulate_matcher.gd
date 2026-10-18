extends Control

@onready var canvas_modulate: CanvasModulate = $"../../CanvasModulate"
@onready var coinlabel: Label = %Coinlabel
@onready var controls_info: TextureRect = %ControlsInfo
@onready var pouch: Control = $Coinlabel/Pouch
@onready var bag_3: TextureRect = $Coinlabel/Pouch/Bag3
@onready var bag_2: TextureRect = $Coinlabel/Pouch/Bag2
@onready var bag_1: TextureRect = $Coinlabel/Pouch/Bag1

@export var jump_height: float = -15.0
@export var jump_scale: float = 1.3
@export var jump_duration: float = 0.25

var player = null
var _last_coins: int = 0
var _pouch_base_position: Vector2
var _pouch_base_scale: Vector2
var _pouch_tween: Tween

func _ready() -> void:
	_pouch_base_position = pouch.position
	_pouch_base_scale = pouch.scale

	call_deferred("_connect_to_player")

func _connect_to_player() -> void:
	player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	_last_coins = player.coins
	_update_coin_display(_last_coins)

	if not player.has_signal("coins_changed"):
		return

	player.connect(
		"coins_changed",
		Callable(self, "_on_player_coins_changed")
	)

func _process(_delta: float) -> void:
	coinlabel.self_modulate = canvas_modulate.color
	controls_info.self_modulate = canvas_modulate.color
	bag_1.self_modulate = canvas_modulate.color
	bag_2.self_modulate = canvas_modulate.color
	bag_3.self_modulate = canvas_modulate.color

func _on_player_coins_changed(new_amount: int) -> void:
	_update_coin_display(new_amount)

	if new_amount > _last_coins:
		_play_coin_jump()

	_last_coins = new_amount

func _update_coin_display(coins: int) -> void:
	coinlabel.text = "Coins: " + str(coins)

	bag_1.visible = coins >= 0 and coins < 40
	bag_2.visible = coins >= 40 and coins < 100
	bag_3.visible = coins >= 100

func _play_coin_jump() -> void:
	if _pouch_tween != null and _pouch_tween.is_running():
		_pouch_tween.kill()

	pouch.position = _pouch_base_position
	pouch.scale = _pouch_base_scale

	var half_duration := maxf(jump_duration * 0.5, 0.01)
	var raised_position := _pouch_base_position + Vector2(0, jump_height)

	_pouch_tween = create_tween()

	_pouch_tween.set_parallel(true)
	_pouch_tween.tween_property(
		pouch, "position", raised_position, half_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	_pouch_tween.tween_property(
		pouch, "scale", _pouch_base_scale * jump_scale, half_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_pouch_tween.set_parallel(false)
	_pouch_tween.tween_property(
		pouch, "position", _pouch_base_position, half_duration
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	_pouch_tween.set_parallel(true)
	_pouch_tween.tween_property(
		pouch, "scale", _pouch_base_scale, half_duration
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
