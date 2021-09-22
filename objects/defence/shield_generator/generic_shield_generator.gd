extends RigidBody2D

var health := 20

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ShieldGenerator_body_entered(body):
	doDamageStuff(body)

#func _on_ShieldGenerator_area_entered(area):
#	doDamageStuff(area)

func doDamageStuff(body):
	print("I, shield generator hit, ", body.name)
	if "damage" in body:
		health -= body.damage
		if health <= 0:
			get_parent().emit_signal("shieldDisabled")
			queue_free()
