extends Area2D

export (String) var levelOwner
var type = UsefullConstantsAndEnums.PLANET
var isReady = false
var firstTime = true
var fromServer : bool
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !firstTime:
		isReady = true


func _on_PlanetShortcutDefault_body_entered(body):
	if "isMyPlayer" in body and body.isMyPlayer == true and isReady == true:
		body.change_my_scene("res://levels/home_steads/default.tscn")

func save():
	var saveDict = {
		levelOwner = levelOwner,
		nodeName = name,
		posX = position.x,
		posY = position.y,
		firstTime = false,
		fromServer = Network.isServer,
	}
	
	
	return saveDict.duplicate(true)

func loadSave(saveDict):
	levelOwner = saveDict["levelOwner"]
	name = saveDict["nodeName"]
	position.x = saveDict["posX"]
	position.y = saveDict["posY"]
	firstTime = saveDict["firstTime"]
	fromServer = saveDict["fromServer"]


