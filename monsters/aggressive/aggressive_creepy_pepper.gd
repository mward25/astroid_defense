extends RigidBody2D
# feature coming soon
export var destroyOnHit = false
export (float) var health = 1
export (float) var speed = 10
export (int) var shootInterval = 0
export (NodePath) var Target
var bullet = preload("res://killy_things/bullets/generic_bullet.tscn")
var count = 5

signal imHit
signal imDead

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if count == 0:
		var Bullet = bullet.instance()
		Bullet.position = $Position2D.position
		add_child(Bullet)
	
	count += 1*delta
	
	if count >= 100:
		count = 0
	
	if health <= 0:
#		print("imDead")
		emit_signal("imDead")
		$AnimatedSprite.play("explode")
		yield($AnimatedSprite, "animation_finished")
		queue_free()

func _physics_process(delta):
	if get_node_or_null(Target) == null:
		print("warning, ", name ,"\'s target is null")
	else:
		if get_node(Target).position.x > position.x:
			applied_force.x += speed
		elif get_node(Target).position.x < position.x:
			applied_force.x -= speed
		
		if get_node(Target).position.y > position.y:
			applied_force.y += speed
		elif get_node(Target).position.y < position.y:
			applied_force.y -= speed


func _on_CreepyPepper_body_entered(body):
	emit_signal("imHit")
#	print("imHit")
#	print(body)
	if destroyOnHit == true:
#		print("meDead")
		if "damage" in body:
#			print("theres damage")
			health -= body.damage
#		print("imHit")

