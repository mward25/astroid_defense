extends Control


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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var playerInfo = {}
var myInfo = {name = "the dude"}

func _on_Button_pressed():
		if $EnterIp/Ip.text == "":
			var peer = NetworkedMultiplayerENet.new()
			peer.create_server(2738, 10)
			get_tree().network_peer = peer
		else:
			var peer = NetworkedMultiplayerENet.new()
			peer.create_client($EnterIp/Ip.text, int($EnterServerPort/Port.text))
			get_tree().network_peer = peer


func update_ui(var info):
	$Names/RichTextLabel.text = playerInfo

remote func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()
	
	var world = load("res://levels/tutorial/tutorial_1.tscn").instance()
	get_node("/root").add_child(world)
	
	
	var MyPlayer = preload("res://player/player_default.tscn").instance()
	MyPlayer.set_name(str(selfPeerID))
	MyPlayer.set_network_master(selfPeerID)
	get_node("/root/world/players").add_child(MyPlayer)
	
	for p in playerInfo:
		var player = preload("res://player/player_default.tscn")
		player.set_name(str(p))
		player.set_network_master(p)
		get_node("/root/world/players").add_child(player)
	
	rpc_id(1, "done_preconfiguring")

func _player_connected(id):
	rpc_id(id, "register_player", myInfo)

func _player_disconnected(id):
	playerInfo.erase(id)

func _connected_ok():
	pass

func _connected_fail():
	pass

remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	playerInfo[id] = info
	
	update_ui(playerInfo[id].name)

