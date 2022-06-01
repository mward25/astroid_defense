extends CanvasLayer
var isInView = true
var menu = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	name = "MenuBringerUpper"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if menu != null:
		if Input.is_action_just_released("activate_menu") && !isInView:
			if menu.get_parent() != null:
				menu.get_parent().remove_child(menu)
			add_child(menu)
			isInView = true
		elif Input.is_action_just_released("activate_menu") && isInView:
			if menu.get_parent() == null:
				add_child(menu)
			menu.get_parent().remove_child(menu)
			isInView = false

@rpc(any) func printIngameConsole(theThing):
	if theThing is String:
		menu.get_node("Display/Display").text += theThing
	else:
		menu.get_node("Display/Display").text += String(theThing)

@rpc(any) func printInGameConsoleLn(theThing):
	printIngameConsole(theThing)
	printIngameConsole("\n")
