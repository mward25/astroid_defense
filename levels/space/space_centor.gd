extends Node2D
const PLANET_SHORTCUT_DEFAULT_FILE = "res://objects/shortcuts/planet/planet_shortcut_default.tscn"
#signal playerEntered
#signal placeHomeStead


func _ready():
	MenuBringerUpper.menu.UnplacedPlanetSelectNodeShortcut.connect("item_selected", self, "_on_UnplacedPlanetSelect_item_selected")
	Saver.updateSpaceScentorSave()
	yield(Saver, "getSpaceCentorSaveFinish")
	
	if Network.myInfo.name in Saver.saveDict[Saver.SAV_SPACE_CENTOR]:
		for theName in Saver.saveDict[Saver.SAV_SPACE_CENTOR]:
			print("adding ", theName, "'s planets")
			var tmpSpaceCentorSaveDict = Saver.saveDict[Saver.SAV_SPACE_CENTOR][theName]
			for thePlanet in Saver.saveDict[Saver.SAV_SPACE_CENTOR][theName]:
					var thePlanetShortcut = tmpSpaceCentorSaveDict[thePlanet]
					
					var ThePlanet = load(thePlanetShortcut[Saver.PLANET_RESOURCE]).instance()
					ThePlanet.placed = true
					ThePlanet.levelOwner = thePlanetShortcut[Saver.PLANET_OWNER]
					ThePlanet.levelName = thePlanetShortcut[Saver.PLANET_NAME]
					ThePlanet.position.x = thePlanetShortcut[Saver.PLANET_IF_PLACED][Saver.PLANET_POSITION_X]
					ThePlanet.position.y = thePlanetShortcut[Saver.PLANET_IF_PLACED][Saver.PLANET_POSITION_Y]
					
					
					ThePlanet.thePlanetResource = thePlanetShortcut[Saver.PLANET_THE_PLANET_RESOURCE]
					add_child(ThePlanet)
#			if tmpSpaceCentorSaveDict[thePlanet][Saver.PLANET_PLACED] == false:
#				MenuBringerUpper.menu.UnplacedPlanetSelect.add_item(tmpSpaceCentorSaveDict[thePlanet][Saver.PLANET_NAME])
#			else:
#				var ThePlanet = load(PLANET_SHORTCUT_DEFAULT_FILE).instance()
#				ThePlanet.loadSave(thePlanet)
#				add_child(ThePlanet)


func _on_UnplacedPlanetSelect_item_selected(index):
	var thePlanet = Saver.saveDict["users"][Network.myInfo.name][MenuBringerUpper.menu.UnplacedPlanetSelectNodeShortcut.get_item_text(index)]
	
	thePlanet[Saver.PLANET_PLACED] = true
	thePlanet[Saver.PLANET_IF_PLACED][Saver.PLANET_POSITION_X] = Shortcuts.playerShortcut.position.x
	thePlanet[Saver.PLANET_IF_PLACED][Saver.PLANET_POSITION_Y] = Shortcuts.playerShortcut.position.y
	
	var ThePlanet = load(thePlanet["resource"]).instance()
	
	ThePlanet.placed = true
	ThePlanet.levelOwner = thePlanet[Saver.PLANET_OWNER]
	ThePlanet.levelName = thePlanet[Saver.PLANET_NAME]
	ThePlanet.position.x = thePlanet[Saver.PLANET_IF_PLACED][Saver.PLANET_POSITION_X]
	ThePlanet.position.y = thePlanet[Saver.PLANET_IF_PLACED][Saver.PLANET_POSITION_Y]
	add_child(ThePlanet)
	Saver.rpc("addMyPlanetToSpacecentor", Network.myInfo.name, thePlanet)

remote func placePlanet(planet : Dictionary):
	pass

#
#const PLANET_SAV_SECTION = "planets"
#
#
#
#var playerEntered = false
#var playerMain
#
#var hasPlacedHomeStead = false
#var isPlacingHomeStead = false
#
#
#
#
#var saveFile = "user://savegame_space_center.save"
#var hasWorld = false
#
#var playersInThisWorld = {}
#
#const PLANET_SHORTCUT_DEFAULT_FILE = "res://objects/shortcuts/planet/planet_shortcut_default.tscn"
#var planetShortcutDefault = preload("res://objects/shortcuts/planet/planet_shortcut_default.tscn")
#
## Declare member variables here. Examples:
## var a = 2
## var b = "text"
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	loadSave()
#	yield(self, "playerEntered")
#	print("player_entered")
#	if hasWorld == false:
#		isPlacingHomeStead = true
#		get_node(playerMain + "/BigMessagingSystem").text = "please go to a place that you would like your first homestead to be, then press click"
#		yield(self, "placeHomeStead")
#		print("placed_homestead")
#		isPlacingHomeStead = false
#
#		var FirstHomeStead = planetShortcutDefault.instance()
#		FirstHomeStead.position = get_node(playerMain).position
#		FirstHomeStead.levelOwner = $"/root/Network".myInfo.name
#
#		add_child(FirstHomeStead)
#		rpc("addMyWorld", PLANET_SHORTCUT_DEFAULT_FILE, FirstHomeStead.save())
#		yield(FirstHomeStead, "draw")
#		hasWorld = true
#		save()
#		FirstHomeStead.isReady = true
#
##	get_node(str(selfPeerID) + "/BigMessagingSystem").text = "please find a place to place your planet"
#
#
#func loadSave():
#	var saveDict : Dictionary
#	var save_game = File.new()
#	var saveData : Dictionary
#	if save_game.file_exists(saveFile) == true:
#		save_game.open(saveFile, File.READ)
#		if save_game.get_as_text() == "":
#			pass
#		else:
#			save()
#			save_game.open(saveFile, File.READ)
#
#		if save_game.get_as_text() == "":
#			hasWorld = false
#		else:
#			saveData = parse_json(save_game.get_as_text())
#			if PLANET_SAV_SECTION in saveData:
#				var planetSaveData = saveData[PLANET_SAV_SECTION]
#				for i in planetSaveData:
#					print("i is ", i)
#					var PlanetShortcutDefault = planetShortcutDefault.instance()
#					PlanetShortcutDefault.loadSave(planetSaveData[i].duplicate(true))
#					if PlanetShortcutDefault.levelOwner == Network.myInfo.name:
#						hasWorld = true
#					add_child(PlanetShortcutDefault)
#
#					rpc("addMyWorld", PLANET_SHORTCUT_DEFAULT_FILE, PlanetShortcutDefault.save())
#
#		if hasWorld == true:
#			pass
#
#		save_game.close()
#		for i in get_children():
#			if "type" in i && i.type == UsefullConstantsAndEnums.PLANET && "levelOwner" in i && i.levelOwner == Network.myInfo.name:
#				if "isReady" in i:
#					i.isReady = true
#				else:
#					print("isReady is not in the planet, it probobly should be")
#
#func save():
#	print("saving ", name)
#	if Network.isServer:
#		pass
#	var saveDict : Dictionary
#	var save_game = File.new()
#	save_game.open(saveFile, File.WRITE)
#
#	saveDict["hasWorld"] = hasWorld
#	for i in get_children():
#
#		# if true is used so that vairiable j will fall out of scope and be deleted
#		if true:
#			var j = 0
#			if "type" in i && i.type == UsefullConstantsAndEnums.PLANET:
#				saveDict[PLANET_SAV_SECTION] = {j:i.save()}
#				j += 1
#
#	save_game.store_string(to_json(saveDict))
#	save_game.close()
#
#
#remote func saveMyWorld():
#	pass
#
#remote func addMyWorld(planet, planetSaveDict : Dictionary):
#	print("the planetSaveDict is: ", planetSaveDict)
#	var Planet = load(planet).instance()
#	for i in get_children():
#		if i.name == planetSaveDict["nodeName"]:
#			i.queue_free()
#	Planet.loadSave(planetSaveDict)
#	add_child(Planet)
#	save()
#
##func save():
##	if selfPeerID == 1:
##		var save_game = File.new()
##		save_game.open(saveFile, File.WRITE)
##
##	else:
##		pass
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if $"/root/Network".myInfo.location == get_path():
#		if playerEntered == false:
#			for p in get_children():
#				if "isMyPlayer" in p and p.isMyPlayer == true:
#					playerEntered = true
#					playerMain = p.name
#					emit_signal("playerEntered", p.name)
#					print(p, "entered")
#
#	for p in $"/root/Network".playerInfo:
#		if "location" in Network.playerInfo[p] && ($"/root/Network".playerInfo[p])["location"] == get_path():
#			if playersInThisWorld.has(p) == true:
#				pass
#			else:
#				playersInThisWorld[p] = $"/root/Network".playerInfo[p]
#	if isPlacingHomeStead == true:
#		if Input.is_action_just_pressed("ui_accept"):
#			emit_signal("placeHomeStead")
#
#
#
#
#func _on_SpaceCentor_playerEntered(player):
#	playerEntered = true
#	playerMain = player
