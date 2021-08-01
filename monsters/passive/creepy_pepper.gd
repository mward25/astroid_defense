extends RigidBody2D
# feature coming soon
export var destroyOnHit = false
export (float) var health = 1
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
	if health <= 0:
#		print("imDead")
		emit_signal("imDead")
		$AnimatedSprite.play("explode")
		yield($AnimatedSprite, "animation_finished")
		queue_free()


func _on_CreepyPepper_body_entered(body):
	emit_signal("imHit")
	if destroyOnHit == true:
		if "damage" in body:
			$HitDisplay.emitting = true
			health -= body.damage

