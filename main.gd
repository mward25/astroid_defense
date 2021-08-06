extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var mainMenu = preload("res://menu/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var MainMenu = mainMenu.instance()
	MainMenu.name = "MainMenu"
	get_node("/root/MenuBringerUpper").menu = MainMenu
	get_node("/root/MenuBringerUpper").call_deferred("add_child", MainMenu)
	queue_free()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
