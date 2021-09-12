extends "res://player/player_base_script.gd"


export (PackedScene) var bullet = preload("res://killy_things/bullets/generic_bullet.tscn")
export (float) var bulletCoolDown = .3
export (float) var bulletSize = 1
var isShooting = false




func calculateShoot():
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
		
func doPlayerTasks():
	calculateShoot()
	.doPlayerTasks()

func tryToShoot(p):
	if isShooting == true:
		rpc_id(p, "shoot_remote")
		isShooting = false

func doRemoteUpdates(p):
	.doRemoteUpdates(p)
	tryToShoot(p)


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
