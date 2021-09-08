extends Node
var passwdFile = "user://passwds.sav"
var saveFile = "user://astroid_defence_save.sav"
onready var SaveFile = File.new()
var saveDict = null

var loginStatus := false

signal updateMySaveDictFinished
signal getSpaceCentorSaveFinished

signal initialSaveDictWritten
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(Network, "isServerDetermined")
	print("isServer has been determined")
	if Network.isServer:
		print("starting to make save file")
		if SaveFile.file_exists(saveFile):
			print("saveFile exists, we are oppening it")
			SaveFile.open(saveFile, File.READ_WRITE)
			print("opened saveFile")
		else:
			print("saveFile does not exist exist, we are creating a new one")
			SaveFile.open(saveFile, File.WRITE_READ)
		print("getting the information from the file")
		saveDict = parse_json(SaveFile.get_as_text())
		print("checking if the dictonary is null or empty")
		if saveDict == null || saveDict.empty():
			print("storing default stuff in the save dict")
			SaveFile.store_string(setupSaveDictAndFile())
			print("made the save file")
			SaveFile.close()
		print("emitting signal initialSaveDictWritten")
		emit_signal("initialSaveDictWritten")
	else:
		print("running on non-server device")
		rpc_id(1, "updateMySaveDict")

# Warning, passwd should always be a hashed string
remote func createUser(username: String, passwd: String):
	var returnValue = false
	
	# if true is used so that all vairiables storing passwords will be deleted afterwords
	if true:
		var tmpPasswdFile = File.new()
		tmpPasswdFile.open(passwdFile, File.READ_WRITE)
		
		var passwdDict = to_json(tmpPasswdFile)
		if passwdDict.has(username):
			returnValue = false
		else:
			passwdDict[username] = passwd
			returnValue = true

remote func login(username: String, passwd: String):
	var senderId
	var tmpPasswdFile = File.new()
	tmpPasswdFile.open(passwdFile, File.READ_WRITE)
	var passwdDict = to_json(tmpPasswdFile)
	
	if passwdDict.has(username) && (passwdDict[username]) == passwd:
		rpc_id(senderId, "setLoginStatus", true)
	else:
		rpc_id(senderId, "setLoginStatus", false)

remote func setLoginStatus(status : bool):
	loginStatus = status

func setupSaveDictAndFile():
	var saveDictTemplate = {
		users = {},
		space_centor = {},
	}
	return to_json(saveDictTemplate)


var tmpSpacecentor = null

remote func addMyPlanetToSpacecentor(user, planet):
	if saveDict == null:
		print("saveDict is null")
	else:
		saveDict["space_centor"][user][planet.name] = planet.save()
		
		rpc_id(1, "getSpaceCenterSave")
		yield(self, "getSpaceCentorSaveFinished")
		var _saveDict = tmpSpacecentor
		_saveDict[user][planet] = planet.save()
		rpc_id(1, "updateSaveDict", _saveDict)
		


remote func getSpaceCenterSave():
	print("gettingSpacecentor")
	rpc_id(get_tree().get_rpc_sender_id(),"getSpaceCentorSave" , saveDict["space_centor"])

remote func getSpaceCentorSave(theDict):
	tmpSpacecentor = theDict
	emit_signal("getSpaceCentorSaveFinished")

remote func updateSpaceScentorSave():
	# if we have not updated our save dict yet, we want to do that first
	if saveDict == null || saveDict.empty():
		print("saveDict not yet written, updating saveDict first")
		rpc_id(1, "updateMySaveDict")
		yield(self, "updateMySaveDictFinished")
	rpc_id(1, "getSpaceCenterSave")
	yield(self, "getSpaceCentorSaveFinished")
	saveDict["space_center"] = tmpSpacecentor

#remote func updateSpaceCentor(spaceCenterDict : Dictionary):
#	saveDict["space_centor"] = spaceCenterDict

remote func updateSaveDict(_saveDict):
	saveDict = _saveDict
	if Network.isServer:
		rpc("updateSaveDict", saveDict)
	emit_signal("updateMySaveDictFinished")
	print("saveDict is now ", saveDict)

remote func updateMySaveDict():
	print("saveDict is ", saveDict)
	if saveDict == null:
		print("saveDict is null, waiting for saveDict to be written")
		yield(self, "initialSaveDictWritten")
		print("saveDict has been written")
	rpc_id(get_tree().get_rpc_sender_id(), "updateSaveDict", saveDict.duplicate())


remote func giveUserPlanet(theUser : String, thePlanetDict : Dictionary):
	saveDict[theUser][thePlanetDict[name]] = thePlanetDict
	updateSaveDict(saveDict)

func generatePlanetDict(name : String, owner : String, resource : String):
	
	var theResource = ""
	if resource == "":
		theResource = "res://objects/shortcuts/planet/planet_shortcut_default.tscn"
	else:
		theResource = resource
	
	return {name=name, owner = owner, resource = theResource}
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
