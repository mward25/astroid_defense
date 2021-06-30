extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_parent().get_node("ActualMessagingSystem/BigMessagingSystem").text = text
	get_parent().get_node("ActualMessagingSystem").offset = get_parent().position
