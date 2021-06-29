extends RigidBody2D
export var damage = 10
enum {BLACK, BLUE, WHITE}
export (int) var color = WHITE
export (float) var killTime = 10

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if color == WHITE:
		$AnimatedSprite.animation = "default"
	elif color == BLUE:
		$AnimatedSprite.animation = "blue"
	elif color == BLACK:
		$AnimatedSprite.animation = "black"
	else:
		$AnimatedSprite.animation = "default"
	$DeathTimer.wait_time = killTime
	$DeathTimer.start()
	yield($DeathTimer, "timeout")
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
