extends Control

@onready var playbutton: Button = %PlayButton
@onready var creditsbutton: Button = %CreditsButton
@onready var quitbutton: Button = %QuitButton
@onready var backbutton: Button = %backbutton
@onready var credits: Control = $Credits

@export var next_scene : PackedScene

@onready var chaakravue: TextureRect = $Credits/Chaakravue
@onready var helena: TextureRect = $Credits/Helena
@onready var kureca_magnet: TextureRect = $Credits/KurecaMagnet
@onready var magda: TextureRect = $Credits/Magda
@onready var mikko: TextureRect = $Credits/Mikko

@export var chaakravue_url: String = ""
@export var helena_url: String = ""
@export var kureca_url: String = ""
@export var magda_url: String = ""
@export var mikko_url: String = ""

const HOVER_SCALE = 2.2
const NORMAL_SCALE = 2.0
const SCALE_SPEED = 10.0

var _portrait_links: Dictionary = {}

func _ready() -> void:
	playbutton.pressed.connect(get_tree().change_scene_to_packed.bind(next_scene))
	creditsbutton.pressed.connect(credits_toggle)
	backbutton.pressed.connect(credits_toggle)
	quitbutton.pressed.connect(get_tree().quit)

	_portrait_links = {
		chaakravue: chaakravue_url,
		helena: helena_url,
		kureca_magnet: kureca_url,
		magda: magda_url,
		mikko: mikko_url
	}

	for portrait in _portrait_links.keys():
		portrait.scale = Vector2.ONE * NORMAL_SCALE
		portrait.mouse_filter = Control.MOUSE_FILTER_STOP

		portrait.mouse_entered.connect(_on_portrait_hover.bind(portrait, true))
		portrait.mouse_exited.connect(_on_portrait_hover.bind(portrait, false))
		portrait.gui_input.connect(_on_portrait_input.bind(portrait))

func credits_toggle():
	credits.visible = !credits.visible

func _on_portrait_hover(portrait: TextureRect, is_hovering: bool) -> void:
	var target_scale = HOVER_SCALE if is_hovering else NORMAL_SCALE
	var tween = create_tween()
	tween.tween_property(portrait, "scale", Vector2.ONE * target_scale, 1.0 / SCALE_SPEED)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_portrait_input(event: InputEvent, portrait: TextureRect) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var url = _portrait_links.get(portrait, "")
		if url != "":
			OS.shell_open(url)
