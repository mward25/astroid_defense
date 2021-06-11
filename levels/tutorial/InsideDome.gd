extends Area2D

var astroid1InDome = false
var astroid2InDome = false
var astroid3InDome = false
var playerInDome = false
signal allAstroidsInDome
signal noAstroidsInDome

signal playerInDomeSignal
signal playernotInDomeSignal

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if astroid1InDome == true and astroid2InDome == true and astroid3InDome == true:
		emit_signal("allAstroidsInDome")
	if astroid1InDome == false and astroid2InDome == false and astroid3InDome == false:
		emit_signal("noAstroidsInDome")
	
	if playerInDome == true:
		emit_signal("playerInDomeSignal")
	elif playerInDome == false:
		emit_signal("playernotInDomeSignal")








func _on_InsideDome_body_entered(body):
	if body == $"../astroid_1":
		astroid1InDome = true
	if body == $"../astroid_2":
		astroid2InDome = true
	if body == $"../astroid_3":
		astroid3InDome = true
	if body == $"../player":
		playerInDome = true


func _on_InsideDome_body_exited(body):
	if body == $"../astroid_1":
		astroid1InDome = false
	if body == $"../astroid_2":
		astroid2InDome = false
	if body == $"../astroid_3":
		astroid3InDome = false
	if body == $"../player":
		playerInDome = false
