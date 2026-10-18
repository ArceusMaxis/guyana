extends Control

@onready var playbutton: Button = %PlayButton
@onready var creditsbutton: Button = %CreditsButton
@onready var quitbutton: Button = %QuitButton
@onready var backbutton: Button = %backbutton
@onready var credits: Control = $Credits

@onready var chaak_button: Button = $Credits/ChaakButton
@onready var mikko_button: Button = $Credits/MikkoButton
@onready var lena_button: Button = $Credits/LenaButton
@onready var magda_button: Button = $Credits/MagdaButton
@onready var kureca_button: Button = $Credits/KurecaButton

@export var next_scene : PackedScene

func _ready() -> void:
	playbutton.pressed.connect(get_tree().change_scene_to_packed.bind(next_scene))
	creditsbutton.pressed.connect(credits_toggle)
	backbutton.pressed.connect(credits_toggle)
	quitbutton.pressed.connect(get_tree().quit)
	chaak_button.pressed.connect(OS.shell_open.bind("https://arceusmaxis.github.io/portfolio/"))
	mikko_button.pressed.connect(OS.shell_open.bind("https://arceusmaxis.github.io/portfolio/"))
	lena_button.pressed.connect(OS.shell_open.bind("https://arceusmaxis.github.io/portfolio/"))
	magda_button.pressed.connect(OS.shell_open.bind("https://arceusmaxis.github.io/portfolio/"))
	kureca_button.pressed.connect(OS.shell_open.bind("https://arceusmaxis.github.io/portfolio/"))

func credits_toggle():
	credits.visible = !credits.visible
