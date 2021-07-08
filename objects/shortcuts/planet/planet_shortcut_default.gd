extends Area2D

export (String) var levelOwner
signal readyToRoll
var isReady = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlanetShortcutDefault_body_entered(body):
	if "isMyPlayer" in body and body.isMyPlayer == true and isReady == true:
		body.change_my_scene("res://levels/home_steads/default.tscn")

func save():
	var save_dict = {
		levelOwner = levelOwner,
		nodeName = name,
		posX = position.x,
		posY = position.y
	}
	
#	we put it into an array to ensure it is saved properly
	var saveDictContainer = []
	saveDictContainer.append(save_dict)
	return to_json(save_dict)

func loadSave(save_data):
	print("save data is ", save_data)
	var save_dict = parse_json(save_data)
	print("save dict is ", save_dict)
	
	levelOwner = save_dict["levelOwner"]
	name = save_dict["nodeName"]
	position.x = save_dict["posX"]
	position.y = save_dict["posY"]


func _on_PlanetShortcutDefault_readyToRoll():
	isReady = true
