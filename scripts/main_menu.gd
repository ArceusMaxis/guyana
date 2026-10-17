extends Control

@onready var playbutton: Button = %PlayButton
@onready var creditsbutton: Button = %CreditsButton
@onready var quitbutton: Button = %QuitButton
@onready var backbutton: Button = %backbutton
@onready var credits: Control = $Credits

@export var next_scene : PackedScene

func _ready() -> void:
	playbutton.pressed.connect(get_tree().change_scene_to_packed.bind(next_scene))
	creditsbutton.pressed.connect(credits_toggle)
	backbutton.pressed.connect(credits_toggle)
	quitbutton.pressed.connect(get_tree().quit)

func credits_toggle():
	credits.visible = !credits.visible
