extends Node
var finishedOnReady = false
signal finishedOnReadySignal
var isServer = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/GlobalAudioPlayer"._play_menu_menu_music()
	emit_signal("finishedOnReadySignal")
	finishedOnReady = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var playerInfo = {}
var myInfo = {name = "the dude"}

func _on_Button_pressed():
	myInfo.name = $NameEdit/TextEdit.text
	if $EnterIp/Ip.text == "":
		isServer = true
		var host = true
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(9278, 10)
		get_tree().network_peer = peer
#		$"/root/Network".playerInfo.host = $NameEdit/TextEdit.text
	else:
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client($EnterIp/Ip.text, int($EnterServerPort/Port.text))
		get_tree().network_peer = peer
#		$"/root/Network".register_player($NameEdit/TextEdit.text)
		isServer = false
#		$"/root/Network".playerInfo.p1 = $NameEdit/TextEdit.text


remote func update_ui(var info):
	$"/root/menu/Names/RichTextLabel".text += info


func _on_StartButton_pressed():
	print($"/root/Network".playerInfo)
	if isServer == false:
		$"/root/Network".pre_configure_game()
