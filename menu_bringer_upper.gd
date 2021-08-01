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
			add_child(menu)
			isInView = true
		elif Input.is_action_just_released("activate_menu") && isInView:
			remove_child(menu)
			isInView = false