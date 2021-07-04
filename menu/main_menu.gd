extends Node
var finishedOnReady = false
signal finishedOnReadySignal
var isServer = false

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
func _process(delta):
	$AudioOnOf/Vcontain/AudioVolume.text = str($"/root/GlobalAudioPlayer".musicVolume)




var playerInfo = {}
var myInfo = {name = "the dude", ship = ""}

func _on_Button_pressed():
	myInfo.name = $NameEdit/TextEdit.text
	if $EnterIp/Ip.text == "":
		isServer = true
		var host = true
		$"/root/Network".myInfo.name = $NameEdit/TextEdit.text
		$"/root/Network".myInfo.ship = myInfo.ship
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(9278, 10)
		get_tree().network_peer = peer
#		$"/root/Network".playerInfo.host = $NameEdit/TextEdit.text
	else:
		$"/root/Network".myInfo.name = $NameEdit/TextEdit.text
		$"/root/Network".myInfo.ship = myInfo.ship
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client($EnterIp/Ip.text, int($EnterServerPort/Port.text))
		get_tree().network_peer = peer
#		$"/root/Network".register_player($NameEdit/TextEdit.text)
		isServer = false
#		$"/root/Network".playerInfo.p1 = $NameEdit/TextEdit.text


func update_ui(var info):
	$"/root/menu/Names/RichTextLabel".text += "\n"
	$"/root/menu/Names/RichTextLabel".text += info


func _on_StartButton_pressed():
	print($"/root/Network".playerInfo)
	queue_free()
	if isServer == false:
		$"/root/Network".pre_configure_game()


func _on_TutorialButton_pressed():
	get_tree().change_scene("res://levels/tutorial/tutorial_1.tscn")







func _on_VolumeSlider_value_changed(value):
	$"/root/GlobalAudioPlayer".musicVolume = value
	print(value)


func _on_ShipSelect_item_selected(index):
	$"/root/CurrentShip".currentShip = $"/root/CurrentShip".shipList[$ShipSelect.get_item_text(index)]
	myInfo["ship"] = $"/root/CurrentShip".currentShip
	print($"/root/CurrentShip".currentShip)
