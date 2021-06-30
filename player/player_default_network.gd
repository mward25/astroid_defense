extends KinematicBody2D

var selfPeerID
export var isMyPlayer = false
var myPos = Vector2()



var velocity = Vector2()
var posTmp = position
var overNet = false
export var speed = 50
export var rotation_dir = 0
export (int) var spin_thrust
export (int) var engine_thrust
export (float) var health = 100

var isThrusting = false

var rotation_limit = 360
var speed_limit = 25
var exaustPower = -120
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():

	if isMyPlayer == true:
		$Camera2D.current = true
	else:
		pass
		
		

func get_input():
	if isMyPlayer == true:
		if Input.is_action_pressed("ui_up"):
			velocity.y -= speed
			$ExaustFumes.gravity = exaustPower
	#		print($FlameAttack.collision_mask)
			$FlameAttack.collision_mask = 1
			$FlameAttack.show()
			isThrusting = true
		else:
			velocity = Vector2()
			$ExaustFumes.gravity = 0
			$FlameAttack.collision_mask = 0
			$FlameAttack.hide()
			isThrusting = false
		
		if Input.is_action_pressed("ui_right"):
			rotation_dir += spin_thrust
		
		if Input.is_action_pressed("ui_left"):
			rotation_dir -= spin_thrust
		
		if Input.is_action_just_pressed("capture_mouse"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if Input.is_action_just_pressed("ui_fullscrean"):
			if OS.window_fullscreen == true:
				OS.window_fullscreen = false
			else:
				OS.window_fullscreen = true
			
	else:
		if isThrusting == true:
			$ExaustFumes.gravity = exaustPower
			$FlameAttack.collision_mask = 1
			$FlameAttack.show()
		elif isThrusting == false:
			velocity = Vector2()
			$ExaustFumes.gravity = 0
			$FlameAttack.collision_mask = 0
			$FlameAttack.hide()


# warning-ignore:unused_argument
func _integrate_forces(state):
	if isMyPlayer == true and overNet == true:
		rpc_unreliable("set_pos_and_motion", position, velocity, rotation_dir, isThrusting)
	rotation = deg2rad(rotation_dir)
	if isMyPlayer == false:
		position = posTmp
#		if isThrusting == true:
#			position = posTmp
#		if rand_range(0,6) >= 5:
#			position = myPos
	

#	position = posTmp

# warning-ignore:unused_argument
func _physics_process(delta):
	get_input()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
#	var myRotLoc = position.rotated(rotation)
	$ExaustFumes.gravity_vec = $ExaustFumes.position
	if health <= 0:
		$BigMessagingSystem.text = "you died"
		yield(get_tree().create_timer(3), "timeout")
		print("I died")
#		we are not dying just yet
#		queue_free()
	
	
	
#	rpc_id(1, "set_pos_and_motion", globalPosition)
	
#	print($ExaustFumes.gravity_vec)


func _on_player_body_entered(body):
	if "damage" in body and body != $FlameAttack:
		health -= body.damage
		print("took ", body.damage, " damage")
		print("my health is now at ", health)



# warning-ignore:unused_argument
# warning-ignore:unused_argument

puppet func set_pos_and_motion(pos, vel, rot_dir, isThrust):
#	myPos = pos
	posTmp = pos
	velocity = vel
	rotation_dir = rot_dir
	isThrusting = isThrust
##	$BigMessagingSystem.text = str(selfPeerID)
###	posTmp = pos
###	velocity = vel
#	rotation_dir = rad2deg(rot)
#	global_position = pos
