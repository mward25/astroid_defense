extends "res://player/player_base_script.gd"

var action = {
	MovementEnums.DO_NOTHING:false,
	MovementEnums.TURN_LEFT:false,
	MovementEnums.TURN_RIGHT:false,
	MovementEnums.THRUST:false,
	}

func setupScene():
	$ActualMessagingSystem/BigMessagingSystem.hide()
	$ActualMessagingSystem/HealthBar.hide()
	if overNet && is_network_master():
		pass
	else:
		mode = RigidBody2D.MODE_KINEMATIC


func calculateMovement():
	if action[MovementEnums.THRUST]:
		activateThrust()
	else:
		# otherwise stop accelerating
		deactivateThrust()



func doPlayerTasks():
#	$ActualMessagingSystem/HealthBar.value = health
	calculateMovement()
	calculateRotation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
