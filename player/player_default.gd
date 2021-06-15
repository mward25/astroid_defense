extends RigidBody2D

var selfPeerID
export var isMyPlayer = false

var velocity = Vector2()
export var speed = 50
export var rotation_dir = 0
export (int) var spin_thrust
export (int) var engine_thrust
export (float) var health = 100
var rotation_limit = 360
var speed_limit = 25
var exaustPower = -120
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if isMyPlayer == true:
		$Camera2D.current = false

func get_input():
	if Input.is_action_pressed("ui_up"):
		velocity.y -= speed
		$ExaustFumes.gravity = exaustPower
#		print($FlameAttack.collision_mask)
		$FlameAttack.collision_mask = 1
		$FlameAttack.show()
	else:
		velocity = Vector2()
		$ExaustFumes.gravity = 0
		$FlameAttack.collision_mask = 0
		$FlameAttack.hide()
	
	if Input.is_action_pressed("ui_right"):
		rotation_dir += spin_thrust
	
	if Input.is_action_pressed("ui_left"):
		rotation_dir -= spin_thrust


func _integrate_forces(state):
	rotation = deg2rad(rotation_dir)

func _physics_process(delta):
	get_input()
	applied_force = velocity.rotated(rotation)
	applied_torque = rotation
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	var myRotLoc = position.rotated(rotation)
	$ExaustFumes.gravity_vec = $ExaustFumes.position
	if health <= 0:
		$BigMessagingSystem.text = "you died"
		yield(get_tree().create_timer(3), "timeout")
		queue_free()
	
	
	rpc("set_pos_and_motion", position, velocity, rotation)
	
#	rpc_id(1, "set_pos_and_motion", globalPosition)
	
#	print($ExaustFumes.gravity_vec)


func _on_player_body_entered(body):
	if "damage" in body:
		health -= body.damage


master func set_pos_and_motion(pos, vel, rot):
	global_position = pos
	velocity = vel
	rotation = rot
#	$BigMessagingSystem.text = str(selfPeerID)
