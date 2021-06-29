extends KinematicBody2D

export (NodePath) var target
var bullet = preload("res://killy_things/bullets/generic_bullet.tscn")

export var speed = .5
var prevAction = PASSIVE
export var shootingIntervall = 2

onready var TargetNode = get_node(target)

enum {ROT_LEFT, ROT_RIGHT, SHOOT, PASSIVE}
var action = PASSIVE



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print(target)
	$ShootTimer.wait_time = shootingIntervall

#365
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if action == PASSIVE:
		pass
	if action == ROT_LEFT:
		$Top.rotation_degrees -= speed
	if action == ROT_RIGHT:
		$Top.rotation_degrees += speed
#	if action == SHOOT:
#		action = prevAction
	
#	if $Top.rotation_degrees <= -265:
#		$Top.rotation_degrees += speed
#	elif $Top.rotation_degrees > 265:
#		$Top.rotation_degrees -= speed
#	elif get_node(target).position.x >= $Top.position.rotated(deg2rad(rotation_degrees)).x:
#		$Top.rotation_degrees -= speed
#	else:
#		$Top.rotation_degrees += speed



func _on_LeftCollision_body_entered(body):
	if body == TargetNode:
		action = ROT_LEFT


func _on_RightCollision_body_entered(body):
	if body == TargetNode:
		action = ROT_RIGHT


func _on_LeftCollision_body_exited(body):
	if body == TargetNode:
		action = ROT_RIGHT



func _on_RightCollision_body_exited(body):
	if body == TargetNode:
		action = ROT_LEFT


func _on_ShootTimer_timeout():
	var Bullet = bullet.instance()
#	Bullet.rotation = $Top.rotation
	Bullet.position = $Top/Top/ShootyPlace.global_position
	Bullet.rotation = $Top.rotation
	Bullet.color = Bullet.BLACK
	Bullet.linear_velocity.y = -500
	Bullet.linear_velocity = Bullet.linear_velocity.rotated($Top.rotation+PI)
#	Bullet.angular_velocity = $Top.rotation + PI
#	print("shooty place positoin: ", $Top/Top/ShootyPlace.global_position, " shooty place rotation: ", $Top/Top/ShootyPlace.rotation)
#	Bullet.position.y -= -100
	get_parent().add_child(Bullet)
