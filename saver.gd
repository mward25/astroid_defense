extends Node
var passwdFile = "user://passwds.sav"
var saveFile = "user://astroid_defence_save.sav"
onready var SaveFile = File.new()
var saveDict = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(Network, "isServerDetermined")
	
	if Network.isServer:
		if SaveFile.file_exists(saveFile):
			SaveFile.open(saveFile, File.READ_WRITE)
		else:
			SaveFile.open(saveFile, File.WRITE_READ)
		saveDict = parse_json((SaveFile.get_as_text()))
		if saveDict == null || saveDict.is_empty():
			SaveFile.store_string(setupSaveDictAndFile())
			SaveFile.close()

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
	var tmpPasswdFile = File.new()
	tmpPasswdFile.open(passwdFile, File.READ_WRITE)
	var passwdDict = to_json(tmpPasswdFile)
	
	if passwdDict.has(username) && (passwdDict[username]) == passwd:
		return saveDict
	else:
		return null

func setupSaveDictAndFile():
	var saveDictTemplate = {
		users = {},
		space_centor = {},
	}
	return to_json(saveDictTemplate)


remote func addMyPlanetToSpacecentor(user, planet):
	if saveDict == null:
		print("saveDict is null")
	else:
		saveDict["space_centor"][user][planet.name] = planet.save()
		updateSaveDict(saveDict)

remote func updateSaveDict(_saveDict):
	saveDict = _saveDict

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
