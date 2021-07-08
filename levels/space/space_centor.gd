extends Node2D
signal playerEntered
var playerEntered = false
var playerMain

var hasPlacedHomeStead = false
var isPlacingHomeStead = false
signal placeHomeStead

var saveFile = "user://savegame_space_center.save"
var hasWorld = false

var playersInThisWorld = {}
#var selfPeerID = get_tree().get_network_unique_id()

var planetShortcutDefault = preload("res://objects/shortcuts/planet/planet_shortcut_default.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	loadSave()
	yield(self, "playerEntered")
	print("player_entered")
	if hasWorld == false:
		isPlacingHomeStead = true
		get_node(playerMain + "/BigMessagingSystem").text = "please go to a place that you would like your first homestead to be, then press click"
		yield(self, "placeHomeStead")
		print("placed_homestead")
		isPlacingHomeStead = false
		
		var FirstHomeStead = planetShortcutDefault.instance()
		FirstHomeStead.position = get_node(playerMain).position
		FirstHomeStead.levelOwner = $"/root/Network".myInfo.name
		
		add_child(FirstHomeStead)
		save()
		FirstHomeStead.emit_signal("readyToRoll")

#	get_node(str(selfPeerID) + "/BigMessagingSystem").text = "please find a place to place your planet"


func loadSave():
	var save_game = File.new()
	
	if save_game.file_exists(saveFile) == true:
		save_game.open(saveFile, File.READ)
	if save_game.get_as_text() == "":
		pass
	else:
		save()
		save_game.open(saveFile, File.READ)
	
	if save_game.get_as_text() == "":
		hasWorld = false
	else:
		hasWorld = true
	
	if hasWorld == true:
#		if true is used so that is is restricted to this scope
		if true:
			var i = 0
			while i <= save_game.get_len():
				var thisLine = save_game.get_line()
				var nextLine = save_game.get_line()
				
				if thisLine != "" and nextLine != "":
					var PlanetShortcutDefault = planetShortcutDefault.instance()
					
					PlanetShortcutDefault.name = thisLine.substr(thisLine.find("[")+1, thisLine.find("]")-1)
					
					PlanetShortcutDefault.loadSave(nextLine)
					
					add_child(PlanetShortcutDefault)
				i += 2
	
	save_game.close()
	for i in get_children():
		if "levelOwner" in i:
			i.emit_signal("readyToRoll")

func save():
	var save_game = File.new()
	save_game.open(saveFile, File.WRITE)
	
	for i in get_children():
		if "levelOwner" in i:
			save_game.store_string("[" + i.name + "]\n")
			
			save_game.store_line(i.save())
	
	
	save_game.close()
	
#func save():
#	if selfPeerID == 1:
#		var save_game = File.new()
#		save_game.open(saveFile, File.WRITE)
#
#	else:
#		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if playerEntered == false:
#		if get_node_or_null(str(selfPeerID)) != null:
#			emit_signal("playerEntered")
#	else:
#		pass
	
	if $"/root/Network".myInfo.location == get_path():
		if playerEntered == false:
			for p in get_children():
				if "isMyPlayer" in p and p.isMyPlayer == true:
					playerEntered = true
					playerMain = p.name
					emit_signal("playerEntered", p.name)
					print(p, "entered")
	
	for p in $"/root/Network".playerInfo:
		if ($"/root/Network".playerInfo[p])["location"] == get_path():
			if playersInThisWorld.has(p) == true:
				pass
			else:
				playersInThisWorld[p] = $"/root/Network".playerInfo[p]
#			print("player ", p, " is here")
	
	if isPlacingHomeStead == true:
		if Input.is_action_just_pressed("ui_accept"):
			emit_signal("placeHomeStead")




func _on_SpaceCentor_playerEntered(player):
	playerEntered = true
	playerMain = player
