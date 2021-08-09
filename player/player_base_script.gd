extends RigidBody2D

var selfPeerID
var type = UsefullConstantsAndEnums.SHIP
export var isMyPlayer = false
var myPos = Vector2()


var velocity = Vector2()
var posTmp = position
var overNet = false
var isDead = false

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
	if isMyPlayer == true:
		$Camera2D.current = true
		$ActualMessagingSystem/HealthBar.min_value = 0
		$ActualMessagingSystem/HealthBar.max_value = health
	else:
		mode = RigidBody2D.MODE_KINEMATIC
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
	if Input.is_action_pressed("ui_right"):
		rotation_dir += spin_thrust
	if Input.is_action_pressed("ui_left"):
		rotation_dir -= spin_thrust

func calculateExhaustEmmissionRemote():
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

func doNonPlayerTasks():
	calculateExhaustEmmissionRemote()

func get_input():
	if isMyPlayer == true:
		doPlayerTasks()
	else:
		doNonPlayerTasks()

func doRemoteUpdates(p):
	movePlayerRemote(p)

func movePlayerRemote(p):
	rpc_unreliable_id(p, "set_pos_and_motion", position, velocity, rotation_dir, isThrusting)

func rotateSelf():
	rotation = deg2rad(rotation_dir)

# warning-ignore:unused_argument
func _integrate_forces(state):
	if isMyPlayer == true and overNet == true:
		if $"/root/Network".playersInMyLocation.size() > 0:
#			print("players in my location: ",  $"/root/Network".playersInMyLocation)
			for p in $"/root/Network".playersInMyLocation:
				doRemoteUpdates(p)
	rotateSelf()

func movePlayerLocal():
	if isMyPlayer == false:
		position = posTmp
	applied_force = velocity.rotated(rotation)
	applied_torque = rotation

# warning-ignore:unused_argument
func _physics_process(delta):
	get_input()
	movePlayerLocal()



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

puppet func set_pos_and_motion(pos, vel, rot_dir, isThrust):
#	myPos = pos
	posTmp = pos
	velocity = vel
	rotation_dir = rot_dir
	isThrusting = isThrust

func change_my_scene(sceneToChangeTo):
	rpc("update_scene_location", sceneToChangeTo)


puppetsync func update_scene_location(sceneToChangeTo):
	$"/root/Network".changeMyScene(get_path(), sceneToChangeTo)



func _exit_tree():
	pass
