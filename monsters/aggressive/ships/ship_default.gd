extends "res://player/player_base_script.gd"

export var oponent : NodePath

enum {GOOD_OUTCOME, BAD_OUTCOME}

var outcome
var tookDamage = true


var action = {
	MovementEnums.DO_NOTHING:false,
	MovementEnums.TURN_LEFT:false,
	MovementEnums.TURN_RIGHT:false,
	MovementEnums.THRUST:false,
}

var proboblilitys : Dictionary

var actionSnippet : Array


class MiniProbRecord:
	var theAction
	var probobility
	var myLocation := Vector2()
	var myOponentsLocation := Vector2()
	
	
	func outputProb():
		return [myLocation, myOponentsLocation]





func updateActionProb():
	var thisSnippet = MiniProbRecord.new()
	
	thisSnippet.theAction = action
	thisSnippet.myLocation = position.rotated(rotation)
	thisSnippet.myOponentsLocation = get_node(oponent).position.rotated(get_node(oponent).rotation)
	
	actionSnippet.append(thisSnippet)
	
	actionSnippet.append(thisSnippet)
	
	if tookDamage == true:
		
		for i in actionSnippet:
			if i != null:
				if i.probobility == null:
					i.probobility = 0.6
				
				if i.probobility - 0.1 <= 0.5:
					i.probobility -= 0.1
				if proboblilitys.has(i.outputProb()):
					proboblilitys.erase(i.outputProb())
				proboblilitys[i.outputProb()] = i.probobility
				actionSnippet.erase(i)
		
		tookDamage = false

func calculateAction():
	var randomNumber
	if proboblilitys.has([position.floor(), get_node(oponent).position.floor()]):
		print("had the position")
		randomNumber = rand_range(proboblilitys[[position, get_node(oponent).position]], 1.0)
		
		if randomNumber >= rand_range(0.3, 0.5):
			print("turned left")
			action[MovementEnums.TURN_LEFT] = true
			action[MovementEnums.TURN_RIGHT] = false
	else:
		action[MovementEnums.TURN_RIGHT] = true
	updateActionProb()

func setupScene():
	$ActualMessagingSystem/BigMessagingSystem.hide()
	$ActualMessagingSystem/HealthBar.hide()
	if overNet:
		if is_network_master():
			pass
		else:
			mode = RigidBody2D.MODE_KINEMATIC

func get_input():
	if overNet:
		if isMyPlayer == true:
			doPlayerTasks()
		else:
			doNonPlayerTasks()
	else:
		doPlayerTasks()


func calculateMovement():
	if action[MovementEnums.THRUST]:
		activateThrust()
	else:
		# otherwise stop accelerating
		deactivateThrust()

func calculateRotation():
	if action[MovementEnums.TURN_RIGHT] == true:
		spinRight()
	if action[MovementEnums.TURN_LEFT] == true:
		spinLeft()

func doPlayerTasks():
	calculateAction()
	calculateMovement()
	calculateRotation()

func takeDamage(body):
	.takeDamage(body)
	outcome = BAD_OUTCOME
	tookDamage = true
