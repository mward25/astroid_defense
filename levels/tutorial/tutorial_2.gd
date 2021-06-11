extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$player/BigMessagingSystem.text = "please enter inside of the building"
	yield($InsideDome, "playerInDomeSignal")
	
	$player/BigMessagingSystem.text = "please put all the astroids in the building"
	yield($InsideDome, "allAstroidsInDome")
	
	$player/BigMessagingSystem.text = "now take them out of the building"
	yield($InsideDome, "noAstroidsInDome")
	
	$player/BigMessagingSystem.text = "congrads you have finished this part of the tutorial"
	yield(get_tree().create_timer(4), "timeout")
	get_tree().change_scene("res://levels/tutorial/tutorial_3.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
