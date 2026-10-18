extends Control

@onready var canvas_modulate: CanvasModulate = $"../../CanvasModulate"

@onready var coinlabel: Label = %Coinlabel
@onready var controls_info: TextureRect = %ControlsInfo

func _process(_delta: float) -> void:
	coinlabel.self_modulate = canvas_modulate.color
	controls_info.self_modulate = canvas_modulate.color
