extends Node2D
signal allCreepyPeppersKilled
var creepyPepper1Killed = false
var creepyPepper2Killed = false
var creepyPepper3Killed = false
var creepyPepper4Killed = false
var moneyEarned = 50


# Called when the node enters the scene tree for the first time.
func _ready():
	$player/BigMessagingSystem.text = "kill all of the aggressive creepy pepers"
	yield(self, "allCreepyPeppersKilled")
	$player/BigMessagingSystem.text = "congradulations, you have finished this tutorial and earned 50 moneys"
	Moneys.money += moneyEarned
	yield(get_tree().create_timer(4), "timeout")
	$player/BigMessagingSystem.text = ""


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
