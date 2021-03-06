extends Area2D


var type = UsefullConstantsAndEnums.PLANET
var placed = false
var thePlanetResource = "res://levels/home_steads/default.tscn"

var levelName
var levelOwner

var isReady = false
var firstTime = true
var fromServer : bool
const WAIT_TIME = 4
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(WAIT_TIME), "timeout")
	isReady = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !firstTime:
		isReady = true


func _on_PlanetShortcutDefault_body_entered(body):
	if "isMyPlayer" in body and body.isMyPlayer == true and isReady == true:
		var ThePlanet = load(thePlanetResource).instance()
		
		ThePlanet.levelOwner = levelOwner
		ThePlanet.levelName = levelName
		ThePlanet.name = levelName
		body.change_my_scene(ThePlanet)

#func save():
#	var saveDict = {
#		levelOwner = levelOwner,
#		nodeName = name,
#		posX = position.x,
#		posY = position.y,
#		firstTime = false,
#		placed = placed,
#		fromServer = Network.isServer,
#	}
#
#
#	return saveDict.duplicate(true)

func loadSave(saveDict):
	if !placed:
		levelOwner = saveDict["levelOwner"]
		name = saveDict["nodeName"]
		position.x = saveDict["posX"]
		position.y = saveDict["posY"]
		firstTime = saveDict["firstTime"]
		fromServer = saveDict["fromServer"]
	else:
		print("error, trying to load save on a thing that has not yet been placed")


