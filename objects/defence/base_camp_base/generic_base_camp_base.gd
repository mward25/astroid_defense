extends RigidBody2D
var takingDamage := false
var health := 100
var isDead := false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass





func _on_BaseCampBase_body_entered(body):
	if takingDamage && !isDead && "damage" in body:
		health -= body.damage
		$Particles.emitting = true
		if health <= 0:
			isDead = true
