extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
		if $EnterIp/Ip.text == "":
			var peer = NetworkedMultiplayerENet.new()
			peer.create_server(2738, 10)
			get_tree().network_peer = peer
		else:
			var peer = NetworkedMultiplayerENet.new()
			peer.create_client($EnterIp/Ip.text, $EnterServerPort/Port.text)
			get_tree().network_peer = peer


remote func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()
	
	var world = load("res://levels/tutorial_1.tscn").instance()
	get_node("/root").add_child(world)
	
	
	var MyPlayer = preload("res://player/player_default.tscn").instance()
	MyPlayer.set_name(str(selfPeerID))
	MyPlayer.set_network_master(selfPeerID)
	get_node("/root/world/players").add_child(MyPlayer)
	
	
	
	
	
