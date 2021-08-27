extends Node
var passwdFile = "user://passwds.sav"
var saveFile = "astroid_defence_save.sav"
onready var SaveFile = File.new()
var saveDict = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	SaveFile.load(saveFile)
	saveDict = to_json(SaveFile.as_string())
	if saveDict.is_empty():
		pass

# Warning, passwd should always be a hashed string
remote func createUser(username: String, passwd: String):
	var returnValue = false
	
	# if true is used so that all vairiables storing passwords will be deleted afterwords
	if true:
		var tmpPasswdFile = File.new()
		tmpPasswdFile.load(passwdFile)
		
		var passwdDict = to_json(tmpPasswdFile)
		if passwdDict.has(username):
			returnValue = false
		else:
			passwdDict[username] = passwd
			returnValue = true
	
	
	

remote func login(username: String, passwd: String):
	var tmpPasswdFile = File.new()
	tmpPasswdFile.load(passwdFile)
	var passwdDict = to_json(tmpPasswdFile)
	
	if passwdDict.has(username) && (passwdDict[username]) == passwd:
		return saveDict
	else:
		return null




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
