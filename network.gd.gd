extends Node
var finishedOnReady = false
signal finishedOnReadySignal
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
var myInfo = {name = "the dude"}



remote func update_ui(var info):
	pass

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
	
	
	var MyPlayer = preload("res://player/player_default.tscn").instance()
	print("adding me, ", str(selfPeerID), " to the scene")
	MyPlayer.set_name(str(selfPeerID))
	MyPlayer.set_network_master(selfPeerID)
	get_node("/root/world").add_child(MyPlayer)
	
	for p in playerInfo:
		var player = preload("res://player/player_default.tscn").instance()
		player.set_name(str(p))
		print("adding ", str(p), " to scene")
		player.set_network_master(int(p))
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
	
	
	var MyPlayer = preload("res://player/player_default.tscn").instance()
	print("adding me, ", str(selfPeerID), " to the scene")
	MyPlayer.set_name(str(selfPeerID))
	MyPlayer.set_network_master(selfPeerID)
	get_node("/root/world").add_child(MyPlayer)
	

	
	var player = preload("res://player/player_default.tscn").instance()
	player.set_name(str(who))
	print("adding ", str(who), " to scene")
	player.set_network_master(int(who))
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
	
	update_ui(playerInfo[id].name)

func _server_disconnected():
	pass



