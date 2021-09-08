extends Node
var passwdFile = "user://passwds.sav"
var saveFile = "user://astroid_defence_save.sav"
onready var SaveFile = File.new()



var saveDict = null
signal initialSaveDictWritten
signal updateMySaveDictFinished
signal getSpaceCentorSaveFinish


var loginStatus := false

enum IncorectPasswdStatus  {BEING_DETERMINED, INCORECT, CORRECT}
var incorectPassword = IncorectPasswdStatus.BEING_DETERMINED
signal loginStatusUpdated




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
remote func createUser(username: String, passwd):
	print("creating user ", username)
	var senderID = get_tree().get_rpc_sender_id()
	var returnValue = false
	
	# if true is used so that all vairiables storing passwords will be deleted afterwords
	if true:
		# Deal with password
		print("dealing with passwords")
		var tmpPasswdFile = File.new()
		tmpPasswdFile.open(passwdFile, File.READ_WRITE)
		
		var passwdDict = parse_json(tmpPasswdFile.get_as_text())
		if passwdDict.has(username):
			returnValue = false
		else:
			passwdDict[username] = passwd
			returnValue = true
	
	print("setting up player")
	# Set up player
	saveDict["users"][username] = {}
	
	
	# give them a planet
	print("giving player a planet")
	giveUserPlanet(senderID, username, generatePlanetDict("default_homestead-" + username, username, ""))
	
	print("setting thier login status")
	rpc_id(senderID, "setLoginStatus", true, IncorectPasswdStatus.CORRECT)
	


remote func login(username: String, passwd: int):
	print("setting senderID")
	var senderId = get_tree().get_rpc_sender_id()
	print("opening tmpPasswd file")
	var tmpPasswdFile = File.new()
	tmpPasswdFile.open(passwdFile, File.READ)
	var passwdDict = to_json(tmpPasswdFile)
	if !(passwdDict == null):
		print("determining if password is valid")
		if passwdDict.has(username) && (passwdDict[username]) == passwd:
			rpc_id(senderId, "setLoginStatus", true, IncorectPasswdStatus.CORRECT)
			print("password is valid")
		elif passwdDict.has(username) && passwdDict[username] != passwd:
			print("username is valid but password is not")
			rpc_id(senderId, "setLoginStatus", false, IncorectPasswdStatus.INCORECT)
		else:
			print("niether username nor password are determined")
			rpc_id(senderId, "setLoginStatus", false, IncorectPasswdStatus.BEING_DETERMINED)
	else:
		print("no password file has been created, saying all logins are invalid")
		rpc_id(senderId, "setLoginStatus", false, IncorectPasswdStatus.BEING_DETERMINED)



remote func setLoginStatus(status : bool, _incorectPassword):
	loginStatus = status
	incorectPassword = _incorectPassword
	emit_signal("loginStatusUpdated")


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


remote func giveUserPlanet(theUserID, theUser : String, thePlanetDict : Dictionary):
	saveDict[theUser][thePlanetDict[name]] = thePlanetDict
	rpc_id(theUserID, "addNewPlanetToUnplacedPlanetSelect")
	updateSaveDict(saveDict)

remote func addNewPlanetToUnplacedPlanetSelect():
	yield(self, "updateMySaveDictFinished")
	MenuBringerUpper.menu.UnplacedPlanetSelectNodeShortcut.clear()
	for thePlanet in saveDict["users"][Network.myInfo.name]:
		if thePlanet.placed == false:
			MenuBringerUpper.menu.UnplacedPlanetSelectNodeShortcut.add_item(thePlanet.name)

func generatePlanetDict(name : String, owner : String, resource : String):
	
	var theResource = ""
	if resource == "":
		theResource = "res://objects/shortcuts/planet/planet_shortcut_default.tscn"
	else:
		theResource = resource
	
	return {name=name, owner = owner, placed = false, resource = theResource}
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
