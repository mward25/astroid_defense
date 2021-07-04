extends Node2D
signal allCreepyPeppersKilled
var creepyPepper1Killed = false
var creepyPepper2Killed = false
var creepyPepper3Killed = false
var creepyPepper4Killed = false
var moneyEarned = 50

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
	$AgressiveCreepyPepper.Target = NodePath("/root/Tutorial3/player")
	$AgressiveCreepyPepper2.Target = NodePath("/root/Tutorial3/player")
	$AgressiveCreepyPepper3.Target = NodePath("/root/Tutorial3/player")
	$AgressiveCreepyPepper4.Target = NodePath("/root/Tutorial3/player")
	
	$player/BigMessagingSystem.text = "kill all of the aggressive creepy pepers"
	yield(self, "allCreepyPeppersKilled")
	$player/BigMessagingSystem.text = "congradulations, you have finished this tutorial and earned 50 moneys"
	Moneys.money += moneyEarned
	yield(get_tree().create_timer(4), "timeout")
	$player/BigMessagingSystem.text = ""
	
	get_tree().change_scene("res://levels/home_steads/default.tscn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if creepyPepper1Killed == true and creepyPepper2Killed == true and creepyPepper3Killed == true and creepyPepper4Killed == true:
		emit_signal("allCreepyPeppersKilled")


func _on_AgressiveCreepyPepper_imDead():
	creepyPepper1Killed = true


func _on_AgressiveCreepyPepper2_imDead():
	creepyPepper2Killed = true


func _on_AgressiveCreepyPepper3_imDead():
	creepyPepper3Killed = true


func _on_AgressiveCreepyPepper4_imDead():
	creepyPepper4Killed = true
