extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var mainMenu = preload("res://menu/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	print("starting astroid defence")
	if "--server" in OS.get_cmdline_args() || OS.has_feature("Server"):
		print("running as server")
		Network.isHeadless = true
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(9278, 10)
		get_tree().network_peer = peer
	else:
		var MainMenu = mainMenu.instance()
		MainMenu.name = "MainMenu"
		get_node("/root/MenuBringerUpper").menu = MainMenu
		get_node("/root/MenuBringerUpper").call_deferred("add_child", MainMenu)
		queue_free()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
