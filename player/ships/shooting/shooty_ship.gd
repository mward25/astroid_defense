extends RigidBody2D

var selfPeerID
export var isMyPlayer = false
var myPos = Vector2()


export (PackedScene) var bullet = preload("res://killy_things/bullets/generic_bullet.tscn")


var velocity = Vector2()
var posTmp = position
var overNet = false
var isDead = false
export var speed = 5
export var rotation_dir = 0
export (int) var spin_thrust = 6
export (int) var engine_thrust = 350
export (float) var health = 100
export (float) var bulletCoolDown = .3
export (float) var bulletSize = 1

var isShooting = false

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
		$ActualMessagingSystem/HealthBar.min_value = 0
		$ActualMessagingSystem/HealthBar.max_value = health
	else:
		mode = RigidBody2D.MODE_KINEMATIC
		$ActualMessagingSystem/BigMessagingSystem.hide()
		$ActualMessagingSystem/HealthBar.hide()
		
		

func get_input():
	if isMyPlayer == true:
		$ActualMessagingSystem/HealthBar.value = health
		if Input.is_action_pressed("shoot") && isDead == false && $ShooterCoolDown.time_left <= 0:
			var Bullet = bullet.instance()
			Bullet.position = position
			Bullet.position -= Vector2(0, 90).rotated(rotation)
			Bullet.linear_velocity = Bullet.linear_velocity.rotated(rotation)
			Bullet.rotation = rotation
			Bullet.scale = Vector2(bulletSize, bulletSize)
			Bullet.killTime = 4
			get_parent().add_child(Bullet)
			$ShooterCoolDown.wait_time = bulletCoolDown
			$ShooterCoolDown.start()
			isShooting = true
		
		if Input.is_action_pressed("ui_up"):
			velocity.y -= speed
			$ExaustFumes.gravity = exaustPower
	#		print($FlameAttack.collision_mask)
			if isDead == false:
				$FlameAttack.collision_mask = 1
				$FlameAttack.show()
				$FlameParticles.emitting = true
			else:
				$FlameAttack.collision_layer = 0
				$FlameAttack.collision_mask = 0
				$FlameAttack.hide()
			isThrusting = true
		else:
			velocity = Vector2()
			$ExaustFumes.gravity = 0
			$FlameAttack.collision_mask = 0
			$FlameAttack.hide()
			$FlameParticles.emitting = false
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
			$FlameParticles.emitting = true
		elif isThrusting == false:
			velocity = Vector2()
			$ExaustFumes.gravity = 0
			$FlameAttack.collision_mask = 0
			$FlameAttack.hide()
			$FlameParticles.emitting = false


# warning-ignore:unused_argument
func _integrate_forces(state):
	if isMyPlayer == true and overNet == true:
		for p in $"/root/Network".playerInfo:
			if ($"/root/Network".playerInfo[p])["location"] == $"/root/Network".myInfo.location:
				print("sending signal to ", p)
				rpc_unreliable_id(p, "set_pos_and_motion", position, velocity, rotation_dir, isThrusting)
				if isShooting == true:
					rpc_id(p, "shoot_remote")
					isShooting = false
	rotation = deg2rad(rotation_dir)
#	if isMyPlayer == false:
#		position = posTmp
#		if isThrusting == true:
#			position = posTmp
#		if rand_range(0,6) >= 5:
#			position = myPos
	

#	position = posTmp

# warning-ignore:unused_argument
func _physics_process(delta):
	get_input()
#	print(selfPeerID)
	if isMyPlayer == false:
		position = posTmp
	applied_force = velocity.rotated(rotation)
	applied_torque = rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
#	var myRotLoc = position.rotated(rotation)
	if Input.is_action_just_pressed("ui_cancel"):
		if isMyPlayer == true and overNet == true:
			for p in $"/root/Network".playerInfo:
				if ($"/root/Network".playerInfo[p])["location"] == $"/root/Network".myInfo.location:
					rpc("update_scene_location", "res://levels/space/space_centor.tscn")
		$"/root/Network".changeMyScene(get_path(), "res://levels/space/space_centor.tscn")
	$ExaustFumes.gravity_vec = $ExaustFumes.position
	if health <= 0:
		$BigMessagingSystem.text = "you died"
		yield(get_tree().create_timer(3), "timeout")
		
#		become a spectator uppon death
		collision_layer = 0
		collision_mask = 0
		isDead = true
#		hide()
#		print("I died")
	
	
	
#	rpc_id(1, "set_pos_and_motion", globalPosition)
	
#	print($ExaustFumes.gravity_vec)


func _on_player_body_entered(body):
	if isDead == false:
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
	

puppet func shoot_remote():
	var Bullet = bullet.instance()
	Bullet.position = position
	Bullet.position -= Vector2(0, 90).rotated(rotation)
	Bullet.linear_velocity = Bullet.linear_velocity.rotated(rotation)
	Bullet.rotation = rotation
	Bullet.scale = Vector2(bulletSize, bulletSize)
	Bullet.killTime = 4
	get_parent().add_child(Bullet)
	$ShooterCoolDown.wait_time = bulletCoolDown
	$ShooterCoolDown.start()

##	$BigMessagingSystem.text = str(selfPeerID)
###	posTmp = pos
###	velocity = vel
#	rotation_dir = rad2deg(rot)
#	global_position = pos




puppet func update_scene_location(sceneToChangeTo):
	print("puppet_changing_scene")
	$"/root/Network".changeMyScene(get_path(), sceneToChangeTo)
