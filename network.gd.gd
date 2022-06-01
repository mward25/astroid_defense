extends Node

signal finishedOnReadySignal

@export var defaultWorld = "res://levels/space/space_centor.tscn"
signal isServerDetermined

var finishedOnReady = false
var playing = false
var isServer = false
var isHeadless = false

#{name = "the dude", ship = "playerDefault", location = ""}
# bellow constants are based on comment above
const INFO_NAME = "name"
const INFO_SHIP = "ship"
const INFO_LOCATION = "location"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("peer_connected",Callable(self,"_player_connected"))
	get_tree().connect("peer_disconnected",Callable(self,"_player_disconnected"))
	get_tree().connect("connected_to_server",Callable(self,"_connected_ok"))
	get_tree().connect("connection_failed",Callable(self,"_connected_fail"))
	get_tree().connect("server_disconnected",Callable(self,"_server_disconnected"))
	emit_signal("finishedOnReadySignal")
	finishedOnReady = true


var playerInfo = {}
var playersInMyLocation = {}
#var myInfo = {name = "the dude", ship = "playerDefault", location = ""}
var myInfo = {}

@rpc(any,sync) func updatePlayersInMyLocation():
	print("checking for players that are in player info")
	for p in $"/root/Network".playerInfo:
		if "location" in playerInfo[p] && ($"/root/Network".playerInfo[p])["location"] == $"/root/Network".myInfo.location:
			playersInMyLocation[p] = playerInfo[p].duplicate(true)
		elif playersInMyLocation.has(p):
			playersInMyLocation.erase(p)
	
	print("checking if players need to be delted from playersInMyLocation")
	for p in Network.playersInMyLocation:
		if !(p in playerInfo):
			playersInMyLocation.erase(p)



func _player_connected(id):
	if !isServer:
		var selfPeerID = get_tree().get_unique_id()
		if selfPeerID == 1:
			isServer = true
		else:
			isServer = false
		emit_signal("isServerDetermined")
	print("player ", id, " has connected")
	
	rpc_id(id, "register_player", myInfo)



@rpc(any) func register_player(info):
	print("player ", info, " is being registered on ", get_tree().get_unique_id())
	var id = get_tree().get_remote_sender_id()
	
	
	playerInfo[id] = info
	
	print("player_info_has_been_changed")
	
	if !isHeadless && String(id) in playerInfo && "name" in playerInfo[id]:
		print("id and name are in playerInfo")
		rpc("update_ui", playerInfo[id].name)
		updatePlayersInMyLocation()


func _player_disconnected(id):
	playerInfo.erase(id)
	if Network.isServer:
		pass
	rpc("updatePlayersInMyLocation")

func _connected_ok():
	pass

func _connected_fail():
	pass



func _server_disconnected():
	pass


#func _process(delta):
#	pass

@rpc(any,sync) func update_ui(info):
	MenuBringerUpper.menu.update_ui(info)

@rpc(any) func pre_configure_game():
	print("preconfiguring")
	
	# wait until function _onready is finished
	if finishedOnReady == false:
		await self.finishedOnReadySignal
	
	# if we are the server make ourselves paused
	if 1 == get_tree().get_remote_sender_id():
		get_tree().set_pause(true)
	
	var selfPeerID = get_tree().get_unique_id()
	
	# load the level we are going to spawn in and place it in /root/world
	var world = load(defaultWorld).instantiate()
	world.set_name("world")
	get_node("/root").add_child(world)
	
	
	# load my players ship
	var MyPlayer = load(myInfo.ship).instantiate()
	
	# setup my players vairiables
	MyPlayer.selfPeerID = selfPeerID # used to identify the player
	MyPlayer.isMyPlayer = true # used to determine if this is the player being played
	MyPlayer.overNet = true
	print("adding me, ", str(selfPeerID), " to the scene")
	MyPlayer.set_name(str(selfPeerID))
	MyPlayer.set_multiplayer_authority(selfPeerID) # the player is set to be a master of itself
	
	# add my player to the world
	get_node("/root/world").add_child(MyPlayer)
	
	# p is the players identifier in playerInfo, which stores all the players, there locations, and the ships they use
	for p in playerInfo:
		if p != null && "ship" in playerInfo[p]:
			# load the ship specified in player info
			var player = load((playerInfo[p])["ship"]).instantiate()
			
			# setup vairiables
			player.overNet = true
			player.selfPeerID = selfPeerID
			player.set_name(str(p))
			print("adding ", str(p), " to scene")
			player.set_multiplayer_authority(int(p))
			# add the player
			get_node("/root/world").add_child(player)
	
	# start function done_preconfiguring on the host
	rpc_id(1, "done_preconfiguring")
	
	emit_signal("isServerDetermined")
	
#	done_preconfiguring()

var players_done = []
@rpc(any) func done_preconfiguring():
	
	var selfPeerID = get_tree().get_unique_id()
	
	if selfPeerID == 1:
		isServer = true
	emit_signal("isServerDetermined")
	
	
	print("done_preconfiguring")
	
	# this is the player who told us that they were done preconfiguring
	var who = get_tree().get_remote_sender_id()
	
	# if we are not headless, we are both player and host
	if !isHeadless:
		var world = load(defaultWorld).instantiate()
		world.set_name("world")
		get_node("/root").add_child(world)
		
		# add my player
		var MyPlayer = load($"/root/CurrentShip".currentShip).instantiate()
		print("adding me, ", str(selfPeerID), " to the scene")
		MyPlayer.isMyPlayer = true
		MyPlayer.overNet = true
		MyPlayer.selfPeerID = selfPeerID
		MyPlayer.set_name(str(selfPeerID))
		MyPlayer.set_multiplayer_authority(selfPeerID)
	#	MyPlayer.set_multiplayer_authority(1)
		get_node("/root/world").add_child(MyPlayer)
		
		# add the player who was done preconfiguring
		var player = load((playerInfo[who])["ship"]).instantiate()
		player.overNet = true
		player.selfPeerID = selfPeerID
		player.set_name(str(who))
		print("adding ", str(who), " to scene")
		player.set_multiplayer_authority(int(who))
		get_node("/root/world").add_child(player)
	
	
	# add them to players done
	players_done.append(who)
	
	# when they are all done post configure game
	if players_done.size() == playerInfo.size():
		rpc("post_configure_game")
		rpc("updatePlayersInMyLocation")
#		post_configure_game()

@rpc(any) func post_configure_game():
	print("post_configure_game")
	# unpause game
	if 1 == get_tree().get_remote_sender_id():
		get_tree().set_pause(false)
		playing = true




"""
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| This is a simple function to change a players scene |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"""
func changeMyScene(pathToMyPlayer, sceneToChangeTo, positionToSpawn: Vector2 = Vector2(0,0)):
	
	# if the player path is invalid tell the User
	if get_node_or_null(pathToMyPlayer) == null:
		print("error, ", pathToMyPlayer, " not found")
	
	# Vairiables
	var playerName = get_node(pathToMyPlayer).name
	var player = get_node(pathToMyPlayer)
	player.name = playerName
	var SceneToChangeTo = null
	if sceneToChangeTo is String:
		SceneToChangeTo = load(sceneToChangeTo).instantiate()
	else:
		SceneToChangeTo = sceneToChangeTo
	
	
#	if it is not on the machine we are playing on, destroy our player
	if player.isMyPlayer == false:
		player.queue_free()
	else:
#		detect if the scene we want to change to exists, if it does not add it
		if get_node_or_null("/root/" + SceneToChangeTo.name) == null:
			
			# add the scene we want to change to
			$"/root/".add_child(SceneToChangeTo)
			
			# detach the player from the old scene
			player.get_parent().remove_child(player)
			
			
			# add player to the scene we want to change to
			get_node("/root/" + SceneToChangeTo.name).add_child(player)
			
			# remove_at old level
			get_node(myInfo.location).queue_free()
			
			# update location for myinfo
			myInfo.location = player.get_parent().get_path()
			
			# update player info on everybody elses computer with new location
			rpc("update_player_info", myInfo)
			
			var selfPeerID = get_tree().get_unique_id()
			
			for p in playerInfo:
				if "location" in playerInfo[p]:
					print("p\'s location is ", (playerInfo[p])["location"])
					print("my location is ", myInfo["location"])
				
				# if the location of the player is the same as my location add the player
				if "location" in playerInfo[p] && (playerInfo[p])["location"] == myInfo.location:
					# load the player
					var playertmp = load((playerInfo[p])["ship"]).instantiate()
					
					# setup vairiables
					playertmp.overNet = true
					playertmp.selfPeerID = selfPeerID
					playertmp.set_name(str(p))
					print("adding ", str(p), " to scene")
					playertmp.set_multiplayer_authority(int(p))
					
					# set position
					playertmp.position = positionToSpawn
					
					# add the player
					get_node(myInfo.location).add_child(playertmp)
					
					# add my player on the other players game
					rpc_id(p, "add_my_player")

@rpc(any) func update_player_info(info):
	print("player ", info, " is being updated")
	var id = get_tree().get_remote_sender_id()
	playerInfo[id] = info
	rpc("updatePlayersInMyLocation")

@rpc(any) func add_my_player():
	var selfPeerID = get_tree().get_unique_id()
	var id = get_tree().get_remote_sender_id()
	var playertmp = load((playerInfo[id])["ship"]).instantiate()
	playertmp.overNet = true
	playertmp.selfPeerID = selfPeerID
	playertmp.set_name(str(id))
	print("adding ", str(id), " to scene")
	playertmp.set_multiplayer_authority(int(id))
	get_node(myInfo.location).add_child(playertmp)
