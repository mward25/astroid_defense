extends AudioStreamPlayer
var menuMusic = null
var defaultHomesteadMusic = null

const MENU_MUSIC_FILE_PATH = "res://my_assets/songs/menu/astroid_battle.ogg"
const DEFAULT_HOMESTEAD_FILE_PATH = "res://my_assets/songs/homesteads/default_homestead_theme.ogg"
var musicVolume = 100
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if musicVolume == 0:
		playing = false
	elif playing == false:
		playing = true
	volume_db = musicVolume/10

func _play_menu_menu_music():
	if menuMusic == null:
		menuMusic = load(MENU_MUSIC_FILE_PATH)
	stream = menuMusic
	play()

func _stop_menu_music():
	stop()
	if menuMusic != null:
		menuMusic = null

func _play_default_homestead_music():
	if defaultHomesteadMusic == null:
		defaultHomesteadMusic = load(DEFAULT_HOMESTEAD_FILE_PATH)
	stream = defaultHomesteadMusic
	play()

func _stop_default_homestead_music():
	stop()
	if defaultHomesteadMusic != null:
		defaultHomesteadMusic = null
