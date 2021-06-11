extends RigidBody2D
var velocity = Vector2()
export var speed = 50
export var rotation_dir = 0
export (int) var spin_thrust
export (int) var engine_thrust
var rotation_limit = 360
var speed_limit = 25
var exaustPower = -120
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
#	print($ExaustFumes.gravity_vec)
