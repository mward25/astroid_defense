extends Node
var finishedOnReady = false
signal finishedOnReadySignal
var playing = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	emit_signal("finishedOnReadySignal")
	finishedOnReady = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var playerInfo = {}
var myInfo = {name = "the dude", ship = "playerDefault", location = ""}



remotesync func update_ui(var info):
	$"/root/menu".update_ui(info)

remote func pre_configure_game():
	print("preconfiguring")
	if finishedOnReady == false:
		yield(self, "finishedOnReadySignal")
	if 1 == get_tree().get_rpc_sender_id():
		get_tree().set_pause(true)
	var selfPeerID = get_tree().get_network_unique_id()
	
	var world = load("res://levels/test/super_simple.tscn").instance()
	world.set_name("world")
	get_node("/root").add_child(world)
	
	
	
	var MyPlayer = load(myInfo.ship).instance()
	MyPlayer.selfPeerID = selfPeerID
	MyPlayer.isMyPlayer = true
	MyPlayer.overNet = true
	print("adding me, ", str(selfPeerID), " to the scene")
	MyPlayer.set_name(str(selfPeerID))
	MyPlayer.set_network_master(selfPeerID)
#	MyPlayer.set_network_master(1)
	get_node("/root/world").add_child(MyPlayer)
	
	for p in playerInfo:
		var player = load((playerInfo[p])["ship"]).instance()
		player.overNet = true
		player.selfPeerID = selfPeerID
		player.set_name(str(p))
		print("adding ", str(p), " to scene")
		player.set_network_master(int(p))
#		player.set_network_master(1)
		get_node("/root/world").add_child(player)
	
	rpc_id(1, "done_preconfiguring")

#	done_preconfiguring()

var players_done = []
remote func done_preconfiguring():
	var selfPeerID = get_tree().get_network_unique_id()
	print("done_preconfiguring")
	var who = get_tree().get_rpc_sender_id()
	
	var world = load("res://levels/test/super_simple.tscn").instance()
	world.set_name("world")
	get_node("/root").add_child(world)
	
	
	var MyPlayer = load($"/root/CurrentShip".currentShip).instance()
	print("adding me, ", str(selfPeerID), " to the scene")
	MyPlayer.isMyPlayer = true
	MyPlayer.overNet = true
	MyPlayer.selfPeerID = selfPeerID
	MyPlayer.set_name(str(selfPeerID))
	MyPlayer.set_network_master(selfPeerID)
#	MyPlayer.set_network_master(1)
	get_node("/root/world").add_child(MyPlayer)
	
	var player = load((playerInfo[who])["ship"]).instance()
	player.overNet = true
	player.selfPeerID = selfPeerID
	player.set_name(str(who))
	print("adding ", str(who), " to scene")
	player.set_network_master(int(who))
#	player.set_network_master(1)
	get_node("/root/world").add_child(player)
	
#	assert(get_tree().is_network_server())
#	assert(who in playerInfo)
#	assert(not who in players_done)
	
	players_done.append(who)
	
	if players_done.size() == playerInfo.size():
		rpc("post_configure_game")
#		post_configure_game()

remote func post_configure_game():
	print("post_configure_game")
	if 1 == get_tree().get_rpc_sender_id():
		get_tree().set_pause(false)
		playing = true


func _player_connected(id):
	print("player ", id, " has connected")
	rpc_id(id, "register_player", myInfo)

func _player_disconnected(id):
	playerInfo.erase(id)

func _connected_ok():
	pass

func _connected_fail():
	pass

remote func register_player(info):
	print("player ", info, " is being registered")
	var id = get_tree().get_rpc_sender_id()
	playerInfo[id] = info
	
	rpc("update_ui", playerInfo[id].name)

func _server_disconnected():
	pass


func changeMyScene(pathToMyPlayer, sceneToChangeTo):
	print("tree_before:")
	$"/root".print_tree_pretty()
	if get_node_or_null(pathToMyPlayer) == null:
		print("error, ", pathToMyPlayer, " not found")
	var playerName = get_node(pathToMyPlayer).name
	var player = get_node(pathToMyPlayer)
	player.name = playerName
	var SceneToChangeTo = load(sceneToChangeTo).instance()
	
	
	
	if player.isMyPlayer == false:
		player.queue_free()
	else:
		if get_node_or_null("/root/" + SceneToChangeTo.name) == null:
			$"/root".add_child(SceneToChangeTo)
			player.get_parent().remove_child(player)
			get_node("/root/" + SceneToChangeTo.name).add_child(player)
			
			get_node(myInfo.location).queue_free()
			
			myInfo.location = player.get_parent().get_path()
			rpc("update_player_info", myInfo)
			var selfPeerID = get_tree().get_network_unique_id()
			for p in playerInfo:
				print("p\'s location is ", (playerInfo[p])["location"])
				print("my location is ", myInfo["location"])
				if (playerInfo[p])["location"] == myInfo.location:
					var playertmp = load((playerInfo[p])["ship"]).instance()
					playertmp.overNet = true
					playertmp.selfPeerID = selfPeerID
					playertmp.set_name(str(p))
					print("adding ", str(p), " to scene")
					playertmp.set_network_master(int(p))
			#		player.set_network_master(1)
					get_node(myInfo.location).add_child(playertmp)
					
					rpc_id(p, "add_my_player")
	
	
	
	print("tree_after:")
	$"/root".print_tree_pretty()

remote func update_player_info(info):
	print("player ", info, " is being updated")
	var id = get_tree().get_rpc_sender_id()
	playerInfo[id] = info

remote func add_my_player():
	var selfPeerID = get_tree().get_network_unique_id()
	var id = get_tree().get_rpc_sender_id()
	var playertmp = load((playerInfo[id])["ship"]).instance()
	playertmp.overNet = true
	playertmp.selfPeerID = selfPeerID
	playertmp.set_name(str(id))
	print("adding ", str(id), " to scene")
	playertmp.set_network_master(int(id))
#	player.set_network_master(1)
	get_node(myInfo.location).add_child(playertmp)
#func _process(delta):
#	if playing == true:
#		for p in playerInfo:
##			get_node("/root/world/" + str(playerInfo.keys()[0])).applied_force = get_node("/root/world/" + str(playerInfo.keys()[0])).velocity.rotated(get_node("/root/world/" + str(playerInfo.keys()[0])).rotation)
##			get_node("/root/world/" + str(playerInfo.keys()[0])).applied_torque = get_node("/root/world/" + str(playerInfo.keys()[0])).rotation
##			get_node("/root/world/" + str(playerInfo.keys()[0])).rotation = deg2rad(get_node("/root/world/" + str(playerInfo.keys()[0])).rotation_dir)


#master func set_pos_and_motion(position, velocity, rotation):
#	var sender = get_tree().get_rpc_sender_id()
#	print("set_pos_and_motion sent by ", sender)
#	if sender == 1:
#		pass
#	elif sender == 0:
##		for some reason the servers id here is showing up as zero, this is a work around for that
#		get_node("/root/world/" + str(1)).applied_force = velocity.rotated(rotation)
#		get_node("/root/world/" + str(1)).applied_torque = rotation
#	else:
#		get_node("/root/world/" + str(sender)).applied_force = velocity.rotated(rotation)
#		get_node("/root/world/" + str(sender)).applied_torque = rotation
#		#	applied_force = velocity.rotated(rotation)
#		#	applied_torque = rotation
#
