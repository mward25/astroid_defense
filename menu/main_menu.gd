extends Node
var finishedOnReady = false
signal finishedOnReadySignal
var isServer = false
var isInView = true
onready var UnplacedPlanetSelectNodeShortcut = $UnplacedPlanetSelect
const AUDIO_OFF_ON_ART ="      /\n    / )))\n---|  )))))\n--- \\ )))\n     \\ \n"

const MENU_IP = "ip"
const MENU_PORT = "port"
const MENU_VOLUME = "volume"
const MENU_NAME = "name"
var menuSaveDefaultFile = "user://menu_save.sav"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
#	$AudioOnOf/Vcontain/VolumeSlider.value = 50
	$"/root/GlobalAudioPlayer"._play_menu_menu_music()
	
	var MenuSaveDefaultFile = File.new()
	MenuSaveDefaultFile.open(menuSaveDefaultFile, File.READ)
	var menuJson = {}
	menuJson = parse_json(MenuSaveDefaultFile.get_as_text())
	if menuJson == null:
		menuJson = {}
	
	if MENU_IP in menuJson:
		$EnterIp/Ip.text = menuJson[MENU_IP]
	if MENU_PORT in menuJson:
		$EnterServerPort/Port.text = menuJson[MENU_PORT]
	if MENU_VOLUME in menuJson:
		$AudioOnOf/Vcontain/VolumeSlider.value = menuJson[MENU_VOLUME]
	else:
		$AudioOnOf/Vcontain/VolumeSlider.value = 50
	if MENU_NAME in menuJson:
		$NameEdit/TextEdit.text = menuJson[MENU_NAME]
	
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
	if $ShipSelect.is_anything_selected():
		if $EnterIp/Ip.text == "":
			isServer = true
			Network.myInfo.name = $NameEdit/TextEdit.text
			Network.myInfo.ship = myInfo.ship
			Network.myInfo.location = myInfo.location
			var peer = NetworkedMultiplayerENet.new()
			peer.create_server(9278, 10)
			get_tree().network_peer = peer
		else:
			if $SaveIP.pressed:
				print("making save file")
				var MenuSaveDefaultFile = File.new()
				MenuSaveDefaultFile.open(menuSaveDefaultFile, File.WRITE_READ)
				var menuSaveDict = {}
				menuSaveDict = parse_json(MenuSaveDefaultFile.get_as_text())
				if menuSaveDict == null:
					menuSaveDict = {}
				menuSaveDict[MENU_IP] = $EnterIp/Ip.text
				menuSaveDict[MENU_PORT] = $EnterServerPort/Port.text
				menuSaveDict[MENU_VOLUME] = $AudioOnOf/Vcontain/VolumeSlider.value
				menuSaveDict[MENU_NAME] = $NameEdit/TextEdit.text
				print("menu stores this info:")
				print(menuSaveDict)
				MenuSaveDefaultFile.store_string(to_json(menuSaveDict))
				MenuSaveDefaultFile.close()
			Network.myInfo.name = $NameEdit/TextEdit.text
			Network.myInfo.ship = myInfo.ship
			Network.myInfo.location = myInfo.location
			var peer = NetworkedMultiplayerENet.new()
			peer.create_client($EnterIp/Ip.text, int($EnterServerPort/Port.text))
			get_tree().network_peer = peer
			isServer = false
	else:
		MenuBringerUpper.printInGameConsoleLn("please select a ship")


func update_ui(var info):
	if MenuBringerUpper.menu.get_parent() == null:
		yield(MenuBringerUpper.menu, "tree_entered")
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


func _on_LoginButton_pressed():
	var passwdString = ($password_enterer/TextEdit.text).hash()
	$password_enterer/TextEdit.text = ""
	
	Saver.rpc_id(1, "login", $NameEdit/TextEdit.text, passwdString)
	yield(Saver, "loginStatusUpdated")
	
	if !Saver.loginStatus && Saver.incorectPassword == Saver.IncorectPasswdStatus.INCORECT:
		$password_enterer/TextEdit.text = "INCORECT PASSWORD"
	elif !Saver.loginStatus:
		Saver.rpc_id(1, "createUser", $NameEdit/TextEdit.text, passwdString)
