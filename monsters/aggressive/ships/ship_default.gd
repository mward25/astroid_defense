extends "res://player/player_base_script.gd"

var action = {
	MovementEnums.DO_NOTHING:false,
	MovementEnums.TURN_LEFT:false,
	MovementEnums.TURN_RIGHT:false,
	MovementEnums.THRUST:false,
}



func calculateAction():
	pass


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
