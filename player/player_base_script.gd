extends RigidBody2D

var selfPeerID
var type = UsefullConstantsAndEnums.SHIP
export var isMyPlayer = false
var myPos = Vector2()

enum TURN_TYPE {NO_TURN, LEFT_TURN, RIGHT_TURN}

var velocity = Vector2()
var posTmp = position
var overNet = false
var isDead = false

var updatePosition = false
signal finishedUpdatingPosition

var the_rotation_direction = TURN_TYPE.NO_TURN

var miniMapDisplay = {}

#var miniMapImages = {
#	UsefullConstantsAndEnums.PLANET:preload("res://my_assets/mini_map_tilemap/PlanetMiniMapIcon.tscn"),
#	UsefullConstantsAndEnums.SHIP:preload("res://my_assets/mini_map_tilemap/PlayerMiniMapIcon.tscn"),
#	UsefullConstantsAndEnums.MONSTER:preload("res://my_assets/mini_map_tilemap/MonsterMiniMapIcon.tscn"),
#}

export var speed = 5
export var rotation_dir = 0
export (int) var spin_thrust = 6
export (int) var engine_thrust = 350
export (float) var health = 500


var RootPath



var isThrusting = false

var rotation_limit = 360
var speed_limit = 25
var exaustPower = -120
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func setupScene():
	get_node("UpdatePositionTimer").connect("timeout", self, "_on_UpdatePositionTimer_timeout")
	if isMyPlayer == true:
		$Camera2D.current = true
		$ActualMessagingSystem/HealthBar.min_value = 0
		$ActualMessagingSystem/HealthBar.max_value = health
	else:
#		mode = RigidBody2D.MODE_KINEMATIC
#		mode = RigidBody2D.MODE_CHARACTER
		$ActualMessagingSystem/BigMessagingSystem.hide()
		$ActualMessagingSystem/HealthBar.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	setupScene()

func CapMouseOrDoFullscrean():
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

func activateThrust():
	# accelerate and make thrustor work
	velocity.y -= speed
	$ExaustFumes.gravity = exaustPower
	
	# if we are not dead make our flame atack do damage
	if isDead == false:
		$FlameAttack.collision_layer = 1
		$FlameAttack.collision_mask = 1
		$FlameAttack.show()
		$FlameParticles.emitting = true
	else:
		$FlameAttack.collision_layer = 0
		$FlameAttack.collision_mask = 0
		$FlameAttack.hide()
		
	# set isThrusting to true
	isThrusting = true

func deactivateThrust():
	velocity = Vector2()
	$ExaustFumes.gravity = 0
	$FlameAttack.collision_mask = 0
	$FlameAttack.hide()
	$FlameParticles.emitting = false
	isThrusting = false

func calculateMovement():
	if Input.is_action_pressed("ui_up"):
		activateThrust()
	else:
		# otherwise stop accelerating
		deactivateThrust()



func calculateRotation():
#	print("calculatingRotation")
	mode = RigidBody2D.MODE_CHARACTER
	the_rotation_direction = TURN_TYPE.NO_TURN
	if Input.is_action_pressed("ui_left"):
#		print("rotating left")
		rotation_dir -= spin_thrust
		the_rotation_direction = TURN_TYPE.LEFT_TURN
	if Input.is_action_pressed("ui_right"):
#		print("rotating right")
		rotation_dir += spin_thrust
		the_rotation_direction = TURN_TYPE.RIGHT_TURN
	
#	if !(Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_left")):
#		the_rotation_direction = TURN_TYPE.NO_TURN

func calculateExhaustEmmissionRemote():
	if isThrusting == true:
		velocity.y -= speed
		$ExaustFumes.gravity = exaustPower
		$FlameAttack.collision_layer = 1
		$FlameAttack.collision_mask = 1
		$FlameAttack.show()
		$FlameParticles.emitting = true
	elif isThrusting == false:
		velocity = Vector2()
		$ExaustFumes.gravity = 0
		$FlameAttack.collision_layer = 0
		$FlameAttack.collision_mask = 0
		$FlameAttack.hide()
		$FlameParticles.emitting = false

func changeZoom():
	if Input.is_action_pressed("zoom_in"):
		$Camera2D.zoom -= Vector2(.1, .1)
	elif Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom += Vector2(.1, .1)
	elif Input.is_action_pressed("zoom_normalise"):
		$Camera2D.zoom = Vector2(1,1)

func doPlayerTasks():
	$ActualMessagingSystem/HealthBar.value = health
	calculateMovement()
	calculateRotation()
	CapMouseOrDoFullscrean()
	changeZoom()
	
	setPlayerShortcutIfNotNull()

func setPlayerShortcutIfNotNull():
	if Shortcuts.playerShortcut == null:
		Shortcuts.playerShortcut = self

func doNonPlayerTasks():
	calculateExhaustEmmissionRemote()
	



func calculateMovementLocal():
#	position += velocity.rotated(rotation)
	if the_rotation_direction == TURN_TYPE.LEFT_TURN:
		rotation += spin_thrust
	elif the_rotation_direction == TURN_TYPE.RIGHT_TURN:
		rotation -= spin_thrust

func get_input():
	if isMyPlayer == true:
		doPlayerTasks()
	else:
		doNonPlayerTasks()

func doRemoteUpdates(p):
	movePlayerRemote(p)

func movePlayerRemote(p):
	rpc_unreliable_id(p, "set_physics", linear_velocity, angular_velocity, isThrusting)
	rpc_unreliable_id(p, "set_rot",      rotation_dir, the_rotation_direction)
	
	if updatePosition:
		rpc_unreliable_id(p, "set_pos_and_motion", position.round(), rotation_dir)
		emit_signal("finishedUpdatingPosition")
#	rpc_unreliable_id(p, "set_vel", velocity.round(), isThrusting, the_rotation_direction)
#	rpc_id(p, "set_pos_and_motion", position, velocity, rotation_dir, isThrusting, the_rotation_direction)

func rotateSelf():
	rotation = deg2rad(rotation_dir)

# warning-ignore:unused_argument
func _integrate_forces(state):
	pass

func movePlayerLocal():
	if isMyPlayer == false:
#		if velocity.y != 0:
#			position = position.move_toward(posTmp, position.distance_to(posTmp)/(abs(velocity.y)/10.0 ))
#		else:
#			position = (position.move_toward(posTmp, position.distance_to(posTmp)/(1.0)))
		#position = posTmp
		#posTmp += (velocity.rotated(rotaation))
		if the_rotation_direction == TURN_TYPE.LEFT_TURN:
			rotation_dir -= spin_thrust
		elif the_rotation_direction == TURN_TYPE.RIGHT_TURN:
			rotation_dir += spin_thrust
#		else:
#			pass
	
	
	applied_force = velocity.rotated(rotation)
	applied_torque = rotation

# warning-ignore:unused_argument
func _physics_process(delta):
	get_input()
	movePlayerLocal()
	rotateSelf()



func updateMessagingSystem():
	if isMyPlayer == true:
		$ActualMessagingSystem/MiniMap/Coardanates.text = str(global_position.x) + ", " + str(global_position.y)

func updateGravityVec():
	$ExaustFumes.gravity_vec = $ExaustFumes.position

func testForDead():
	if health <= 0:
		$BigMessagingSystem.text = "you died"
		yield(get_tree().create_timer(3), "timeout")
		
#		become a spectator uppon death
		collision_layer = 0
		collision_mask = 0
		isDead = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	updateMessagingSystem()
	updateGravityVec()
	if isMyPlayer == true and overNet == true:
		if $"/root/Network".playersInMyLocation.size() > 0:
#			print("players in my location: ",  $"/root/Network".playersInMyLocation)
			for p in $"/root/Network".playersInMyLocation:
				doRemoteUpdates(p)
	testForDead()

func takeDamage(body):
	health -= body.damage
	print("took ", body.damage, " damage")
	print("my health is now at ", health)

func iHitBody(body):
	# if the body we hit can do damage do it unless it is $FlameAtack
	if isDead == false:
		if "damage" in body and body != $FlameAttack:
			health -= body.damage
			print("took ", body.damage, " damage")
			print("my health is now at ", health)

func _on_player_body_entered(body):
	iHitBody(body)



# warning-ignore:unused_argument
# warning-ignore:unused_argument

puppet func set_pos_and_motion(pos : Vector2, rot_dir):
#	myPos = pos
#	posTmp = pos
	position = pos
	rotation_dir = rot_dir



puppet func set_physics(_linear_velocity, _angular_velocity, _isThrusting):
	linear_velocity = _linear_velocity
	angular_velocity = _angular_velocity
	isThrusting = _isThrusting



puppet func set_rot(_rotation_dir, _the_rotation_direction):
	rotation_dir = _rotation_dir
	the_rotation_direction = _the_rotation_direction

puppet func set_vel( vel : Vector2, isThrust : bool, turnDirect):
	velocity = vel
	isThrusting = isThrust
	the_rotation_direction = turnDirect

func change_my_scene(sceneToChangeTo):
	rpc("update_scene_location", sceneToChangeTo)


puppetsync func update_scene_location(sceneToChangeTo):
	$"/root/Network".changeMyScene(get_path(), sceneToChangeTo)

func _on_UpdatePositionTimer_timeout():
	updatePosition = true
	yield(self, "finishedUpdatingPosition")
	updatePosition = false

func _exit_tree():
	pass
