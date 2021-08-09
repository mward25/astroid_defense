extends Node
var finishedOnReady = false
signal finishedOnReadySignal
var isServer = false
var isInView = true
const AUDIO_OFF_ON_ART ="      /\n    / )))\n---|  )))))\n--- \\ )))\n     \\ \n"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioOnOf/Vcontain/VolumeSlider.value = 50
	$"/root/GlobalAudioPlayer"._play_menu_menu_music()
	emit_signal("finishedOnReadySignal")
	finishedOnReady = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	$AudioOnOf/Vcontain/AudioVolume.text = str($"/root/GlobalAudioPlayer".musicVolume)






var playerInfo = {}
var myInfo = {name = "the dude", ship = "", location = "/root/world"}

func _on_Button_pressed():
	myInfo.name = $NameEdit/TextEdit.text
	if $EnterIp/Ip.text == "":
		isServer = true
		Network.myInfo.name = $NameEdit/TextEdit.text
		Network.myInfo.ship = myInfo.ship
		Network.myInfo.location = myInfo.location
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(9278, 10)
		get_tree().network_peer = peer
	else:
		Network.myInfo.name = $NameEdit/TextEdit.text
		Network.myInfo.ship = myInfo.ship
		Network.myInfo.location = myInfo.location
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client($EnterIp/Ip.text, int($EnterServerPort/Port.text))
		get_tree().network_peer = peer
		isServer = false


func update_ui(var info):
	yield(self, "tree_entered")
	get_node(String(MenuBringerUpper.menu.get_path()) + "/Names/RichTextLabel").text += "\n"
	get_node(String(MenuBringerUpper.menu.get_path()) +"/Names/RichTextLabel").text += info


func _on_StartButton_pressed():
	print(Network.playerInfo)
	get_parent().remove_child(get_node(get_path()))
#	queue_free()
	if isServer == false:
		Network.pre_configure_game()


func _on_TutorialButton_pressed():
	Network.myInfo.name = $NameEdit/TextEdit.text
	Network.myInfo.ship = myInfo.ship
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://levels/tutorial/tutorial_1.tscn")







func _on_VolumeSlider_value_changed(value):
	$"/root/GlobalAudioPlayer".musicVolume = value
	print(value)


func _on_ShipSelect_item_selected(index):
	$"/root/CurrentShip".currentShip = $"/root/CurrentShip".shipList[$ShipSelect.get_item_text(index)]
	myInfo["ship"] = $"/root/CurrentShip".currentShip
	print($"/root/CurrentShip".currentShip)
