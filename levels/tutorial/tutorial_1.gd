extends Node2D
var collideAstriod1 = false
var collideAstriod2 = false
var collideAstriod3 = false
var hitAstroid1 = false
var hitAstroid2 = false
var hitAstroid3 = false
var wantTestHitAstroids = false

var CreepyPepper = preload("res://monsters/passive/creepy_pepper.tscn").instance()
signal hitAllAstriods
signal playerInMessagingArea

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func testFor3AstriodsHit():
	wantTestHitAstroids = true

func addMyPlayer():
	var player = load($"/root/CurrentShip".currentShip).instance()
#	syncronise vairiables from player instansed to the scene through editor
	player.isMyPlayer = $player.isMyPlayer
	player.health = $player.health
	player.spin_thrust = $player.spin_thrust
	player.speed = $player.speed
	player.engine_thrust = $player.engine_thrust
	player.position = $player.position
	player.rotation = $player.rotation
	
	$player.queue_free()
	yield($player, "tree_exited")
	player.name = "player"
	
	add_child(player)

# Called when the node enters the scene tree for the first time.
func _ready():
	addMyPlayer()
	
	
	
	$player/BigMessagingSystem.text = "Hello, when you want to see the next step of the tutorial please move to the red box"
	$InMessagingArea.show()
	
	
	
	yield(get_tree().create_timer(4.0), "timeout")
	
#	print("no more waiting")
	$InMessagingArea.hide()
	
	$player/BigMessagingSystem.text = "use w a s and d to move to hit each astriod"
	wantTestHitAstroids = true
	yield(self, "hitAllAstriods")
	
	$player/BigMessagingSystem.text = "please move back to red box"
	$InMessagingArea.show()
	
	yield(self, "playerInMessagingArea")
	$InMessagingArea.hide()
	
	$player/BigMessagingSystem.text = "kill the creepy pepper by hitting it with your exauhst"
	CreepyPepper.destroyOnHit = true
	add_child(CreepyPepper)
	yield(CreepyPepper, "imDead")
	$player/BigMessagingSystem.text = "please move back to red box"
	$InMessagingArea.show()
	yield(self, "playerInMessagingArea")
	$InMessagingArea.hide()
	
	$player/BigMessagingSystem.text = "now try killing this Creepy Pepper"
	CreepyPepper = preload("res://monsters/passive/creepy_pepper.tscn").instance()
	CreepyPepper.destroyOnHit = true
	CreepyPepper.health = 100
	add_child(CreepyPepper)
	yield(CreepyPepper, "imDead")
	
	$player/BigMessagingSystem.text = "please move back to red box"
	$InMessagingArea.show()
	
	yield(self, "playerInMessagingArea")
	$InMessagingArea.hide()
	
	$player/BigMessagingSystem.text = "Congrads, you have finished the start of the tutorial!"
	
	print("done with tutorial!")
	
	yield(get_tree().create_timer(4), "timeout")
	get_tree().change_scene("res://levels/tutorial/tutorial_2.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	print("hitAstroid1")
#	print(hitAstroid1)
#	print("hitAstroid2")
#	print(hitAstroid2)
#	print("hitAstroid3")
#	print(hitAstroid3)
	if hitAstroid1 == true and hitAstroid2 == true and hitAstroid3 == true:
		emit_signal("hitAllAstriods")


func _on_astroid_1_body_shape_entered(body_id, body, body_shape, local_shape):
	if wantTestHitAstroids == true:
		collideAstriod1 = true
		hitAstroid1 = true


func _on_astroid_2_body_shape_entered(body_id, body, body_shape, local_shape):
	if wantTestHitAstroids == true:
		collideAstriod2 = true
		hitAstroid2 = true


func _on_astroid_3_body_shape_entered(body_id, body, body_shape, local_shape):
	if wantTestHitAstroids == true:
		collideAstriod3 = true
		hitAstroid3 = true


func _on_astroid_3_body_shape_exited(body_id, body, body_shape, local_shape):
	if wantTestHitAstroids == true:
		collideAstriod1 = false


func _on_astroid_2_body_shape_exited(body_id, body, body_shape, local_shape):
	if wantTestHitAstroids == true:
		collideAstriod2 = false


func _on_astroid_1_body_shape_exited(body_id, body, body_shape, local_shape):
	if wantTestHitAstroids == true:
		collideAstriod3 = false


func _on_InMessagingArea_body_entered(body):
	if body == $player:
		emit_signal("playerInMessagingArea")
