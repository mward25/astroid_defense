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

const SAV_USERS = "users"
const SAV_USER_MONEY = "money"
const SAV_SPACE_CENTOR = "space_centor"


# {name=name, owner = owner, placed = false, resource = theResource, ifPlaced = {posX = null, posY = null}}
# Planet Dictonary Constants based off of comment above which was taken from the generatePlanet function
const PLANET_NAME = "name"
const PLANET_OWNER = "owner"
const PLANET_PLACED = "placed"
const PLANET_RESOURCE = "resource"
const PLANET_IF_PLACED = "ifPlaced"
const PLANET_POSITION_X = "posX"
const PLANET_POSITION_Y = "posY"
const PLANET_THE_PLANET_RESOURCE = "thePlanetResource"
const PLANET_THE_PLANET_SAVE = "thePlanetSave"

const JSON_BEAUTIFIER_PATH = "res://addons/json_beautifier/json_beautifier.gd"

const JsonBeautifier = preload(JSON_BEAUTIFIER_PATH)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"





# Called when the node enters the scene tree for the first time.
func _ready():
	# wait for correct settings to be determined
	yield(Network, "isServerDetermined")
	print("isServer has been determined")
	if true:
		var theOutput = []
		var exit_code = OS.execute("ls", ["/"], true, theOutput)
		print("output is ", theOutput, "exit_code is ", exit_code)
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
			print("making git repo for saveDict")
			OS.execute("bash", ["cd " + OS.get_user_data_dir(), " && git init"])
			SaveFile.store_string(setupSaveDictAndFile())
			print("made the save file")
			print("user_data_dir is ", OS.get_user_data_dir())
			var theOutput = []
			var exit_code = OS.execute("bash ", ["cd " +  OS.get_user_data_dir() + " && echo bash may have worked && git add . && git commit -m \"added initial save files\" && ls"], true, theOutput)
			
			print("output is ", theOutput, " the exit code is ", exit_code)
			saveDict = parse_json(SaveFile.get_as_text())
			SaveFile.close()
		print("emitting signal initialSaveDictWritten")
		emit_signal("initialSaveDictWritten")
	else:
		print("running on non-server device")
		rpc_id(1, "updateMySaveDict")
	
	print("after _on_ready saveDict is ", saveDict)

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
		if !tmpPasswdFile.file_exists(passwdFile):
			tmpPasswdFile.open(passwdFile, File.WRITE_READ)
		else:
			tmpPasswdFile.open(passwdFile, File.READ_WRITE)
		 
		
		var passwdDict = parse_json(tmpPasswdFile.get_as_text())
		
		# if the passwdDict is not a dictonary, make it one
		if passwdDict == null:
			passwdDict = {}
		
		if passwdDict.has(username):
			#returnValue = false
			pass
		else:
			passwdDict[username] = passwd
			tmpPasswdFile.store_string(to_json(passwdDict))
			#returnValue = true
		
		
		
		
	
	print("setting up player")
	
	# Set up player
	if !saveDict.has(SAV_USERS):
		saveDict[SAV_USERS] = {}
	saveDict[SAV_USERS][username] = {}
	saveDict[SAV_USERS][username][SAV_USER_MONEY] = 50
	saveDict[SAV_SPACE_CENTOR][username] = {}
	
	
	# give them a planet
	print("giving player a planet")
	giveUserPlanet(senderID, username, generatePlanetDict("default_homestead-" + username, username, ""))
	
	saveSaveDict()
	
	print("setting thier login status")
	rpc_id(senderID, "setLoginStatus", true, IncorectPasswdStatus.CORRECT)
	


remote func login(username: String, passwd: int):
	print("setting senderID")
	var senderId = get_tree().get_rpc_sender_id()
	print("opening tmpPasswd file")
	var tmpPasswdFile = File.new()
	tmpPasswdFile.open(passwdFile, File.READ)
	var passwdDict = parse_json(tmpPasswdFile.get_as_text())
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
		saveDict[SAV_SPACE_CENTOR][user][planet.name] = planet
		if saveDict[SAV_USERS][user].has(planet.name):
			saveDict[SAV_USERS][user].erase(planet.name)
		else:
			print("saveDict[SAV_USERS][user].has(planet.name) was false for some reason")
		if Network.isServer:
			updateSaveDict(saveDict)
			saveSaveDict()
		else:
			print("warning, modifying server from a client, should be used sparringly")
			rpc_id(1, "updateSaveDict", saveDict)
			
		
		
#		rpc_id(1, "getSpaceCenterSave")
#		yield(self, "getSpaceCentorSaveFinish")
#		var _spaceSaveDict = tmpSpacecentor
#		_spaceSaveDict[user][planet] = planet.save()
#		rpc_id(1, "updateSaveDict", _spaceSaveDict)


remote func getSpaceCenterSave():
	print("gettingSpacecentor")
	rpc_id(get_tree().get_rpc_sender_id(),"getSpaceCentorSave" , saveDict[SAV_SPACE_CENTOR])

remote func getSpaceCentorSave(theDict):
	tmpSpacecentor = theDict
	emit_signal("getSpaceCentorSaveFinish")

remote func updateSpaceScentorSave():
	# if we have not updated our save dict yet, we want to do that first
	if saveDict == null || saveDict.empty():
		print("saveDict not yet written, updating saveDict first")
		rpc_id(1, "updateMySaveDict")
		yield(self, "updateMySaveDictFinished")
	rpc_id(1, "getSpaceCenterSave")
	yield(self, "getSpaceCentorSaveFinish")
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
	saveDict[SAV_USERS][theUser][thePlanetDict["name"]] = thePlanetDict
	rpc_id(theUserID, "addNewPlanetToUnplacedPlanetSelect")
	print("the saveDict is ", saveDict)
	updateSaveDict(saveDict)

remote func addNewPlanetToUnplacedPlanetSelect():
	yield(self, "updateMySaveDictFinished")
	MenuBringerUpper.menu.UnplacedPlanetSelectNodeShortcut.clear()
	var tmpUserPlanetDict = saveDict[SAV_USERS][Network.myInfo.name]
	for thePlanet in saveDict[SAV_USERS][Network.myInfo.name]:
		if tmpUserPlanetDict[thePlanet]["placed"] == false:
			MenuBringerUpper.menu.UnplacedPlanetSelectNodeShortcut.add_item(tmpUserPlanetDict[thePlanet]["name"])

func generatePlanetDict(name : String, owner : String, resource : String, planetResource : String = "res://levels/home_steads/default.tscn"):
	
	var theResource = ""
	if resource == "":
		theResource = "res://objects/shortcuts/planet/planet_shortcut_default.tscn"
	else:
		theResource = resource
	
	return {name=name, owner = owner, placed = false, resource = theResource, thePlanetResource = planetResource , ifPlaced = {posX = null, posY = null}, thePlanetSave = {}}

remote func saveHomestead(owner : String, levelName : String, homesteadSaveDict : Dictionary):
	# save the homestead
	saveDict[SAV_SPACE_CENTOR][owner][levelName][PLANET_THE_PLANET_SAVE] = homesteadSaveDict
	
	# if we are the server update everybody elses version of our homestead
	if Network.isServer == true:
		updateSaveDict(saveDict)
		saveSaveDict()
	else:
		rpc_id(1, "updateSaveDict", saveDict)
		rpc_id(1, "saveSaveDict")
		print("warning, updating savedict on server from client, BAD_IDEA")

# saves the saveDict to a files
remote func saveSaveDict():
	SaveFile.open(saveFile, File.WRITE_READ)
	SaveFile.store_string(JSONBeautifier.beautify_json(to_json(saveDict)))
	SaveFile.close()
	OS.execute("cd", [OS.get_user_data_dir(), "&& echo this is a test for bash && git add . && git commit -m updatedSaveDict"])

remote func giveUserMoney(theUser : String, theMoney : int):
	if saveDict[SAV_USERS][theUser][SAV_USER_MONEY] == null:
		saveDict[SAV_USERS][theUser][SAV_USER_MONEY] = theMoney
	saveDict[SAV_USERS][theUser][SAV_USER_MONEY] += theMoney
	print(theUser, "'s money is now ", saveDict[SAV_USERS][theUser][SAV_USER_MONEY])

remote func takeUserMoney(theUser: String, theMoney : int):
	saveDict[SAV_USERS][theUser][SAV_USER_MONEY] -= theMoney

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
