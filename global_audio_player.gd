extends AudioStreamPlayer
var menuMusic = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _play_menu_menu_music():
	if menuMusic == null:
		menuMusic = load("res://my_assets/songs/menu/astroid_battle.ogg")
	stream = menuMusic
	play()

func _stop_menu_music():
	stop()
	if menuMusic != null:
		menuMusic = null
