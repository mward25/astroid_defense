extends Node
export (String) var currentShip
export (Dictionary) var shipList
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	shipList["playerDefault"] = "res://player/player_default.tscn"
	shipList["shootyShip"] = "res://player/ships/shooting/shooty_ship.tscn"
	currentShip = shipList["shootyShip"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
