extends Node2D


var saveDataBaseDict : Dictionary
const GENERIC_TURRET = 2
const GENERIC_SHIELD_GENERATOR = 3
var currentBlock = 0
export (Array) var targets = []

signal loadSaveFinished
signal activateLevel

var saveFile = "user://savegame_default_homestead.save"


onready var upperTileMapBounds = $TileMap.tile_set.get_tiles_ids().max()
onready var lowerTileMapBounds = $TileMap.tile_set.get_tiles_ids().min()

onready var genericTurrets = $TileMap.get_used_cells_by_id(2)
var genericTurret = preload("res://objects/defence/turrets/generic_turret.tscn")

signal playerEntered
var playerEntered = false
var playerMain

var levelOwner = null
var levelName = null

var isLevelOwner = false
var flipXBlock = false
var flipYBlock = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"



func addMyPlayer():
	var player = load($"/root/CurrentShip".currentShip).instance()
#	syncronise vairiables from player instansed to the scene through editor
	player.isMyPlayer = $player.isMyPlayer
	player.health = $player.health
	player.spin_thrust = $player.spin_thrust
	player.speed = $player.speed
	player.engine_thrust = $player.engine_thrust
	player.position = $player.position
	player.rotation = $player.rotation
	
	$player.queue_free()
	yield($player, "tree_exited")
	player.name = "player"
	
	add_child(player)
	yield($player, "tree_entered")

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalAudioPlayer._play_default_homestead_music()
	yield(self, "playerEntered")
	name = levelName
#	yield(get_node(playerMain), "draw")
	targets.append(get_node(playerMain).get_path())
	
	loadSave()
	yield(self, "loadSaveFinished")
	
	if levelOwner == $"/root/Network".myInfo.name:
		isLevelOwner = true
	else:
		isLevelOwner = false
	
#	isLevelOwner = $"/root/Network".myInfo.name == levelOwner
	print("LevelOwner is ", levelOwner)
	print("name is ", $"/root/Network".myInfo.name)
	print("isLevelOwner is ", isLevelOwner)
	if isLevelOwner == false:
		emit_signal("activateLevel")
	
	$TileMap.tile_set = preload("res://my_assets/retro_tilemap/retro_tileset.tres")
#	print("upper: ", upperTileMapBounds, "\nlower: ", lowerTileMapBounds)
#	$TileMap.set_cellv(Vector2(0, 0), 0)
	

func save():
	var saveNodes = get_tree().get_nodes_in_group("persist")
	saveDataBaseDict["node"] = name
	saveDataBaseDict["owner"] = $"/root/Network".myInfo.name
	
	for i in saveNodes:
		saveDataBaseDict[i.name] = i.save()
	
#	SaveDataBase.create_table(name, saveDataBaseDict)
	
	Saver.rpc_id(1, "saveHomestead", levelOwner, levelName, saveDataBaseDict)
	
#	var save_game = File.new()
#	save_game.open(saveFile, File.WRITE)
#
#	save_game.store_string(to_json(saveDataBaseDict))
#
#	save_game.close()

func loadSave():
	var saveNodes = get_tree().get_nodes_in_group("persist")
	
	
	
#	var save_game = File.new()
#	if save_game.file_exists(saveFile):
#		save_game.open(saveFile, File.READ)
#	else:
#		save()
#		save_game.open(saveFile, File.READ)
	Saver.updateMySaveDict()
	yield(Saver, "updateMySaveDictFinished")
	
	var saveDict = Saver.saveDict[Saver.SAV_SPACE_CENTOR][levelOwner][levelName][Saver.PLANET_THE_PLANET_SAVE]
	
	
	name = levelName
	# name = saveDict["node"]
	# levelOwner =  saveDict["owner"]
	
	
	for i in saveNodes:
		if i.name in saveDict:
			i.loadSave(saveDict[i.name].duplicate(true))
	emit_signal("loadSaveFinished")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $"/root/Network".myInfo.location == get_path():
		if playerEntered == false:
			for p in get_children():
				if "isMyPlayer" in p and p.isMyPlayer == true:
					playerEntered = true
					playerMain = p.name
					emit_signal("playerEntered", p)
					print(p, "entered")
	if playerEntered == true:
		if get_node(playerMain).position.y  <= $GoToSpace.position.y:
			get_node(playerMain).change_my_scene("res://levels/space/space_centor.tscn")
	if isLevelOwner == true:
		$MouseCurser.position = Vector2(((int(get_global_mouse_position().x)/64)*64)+32, ((int(get_global_mouse_position().y)/64)*64)+32)
		var mouseXCord = get_global_mouse_position().x/64.0
		var mouseYCord = get_global_mouse_position().y/64.0
		
		var currentBlockTexture = $TileMap.tile_set.tile_get_texture(currentBlock)
		var currentBlockRegion = $TileMap.tile_set.tile_get_region(currentBlock)
		#	var currentBlockOffset = $TileMap.tile_set.tile_get_texture_offset(currentBlock)
		
	#	$MouseCurser.region_rect.position = currentBlockOffset
		$MouseCurser.region_rect = currentBlockRegion
		$MouseCurser.flip_h = flipXBlock
		$MouseCurser.flip_v = flipYBlock
		$MouseCurser.texture = currentBlockTexture
		
		if Input.is_action_just_pressed("activate_level"):
			emit_signal("activateLevel")
		
		if Input.is_action_just_pressed("ui_save"):
			save()
		elif Input.is_action_just_pressed("ui_load"):
			loadSave()
		
		if Input.is_action_pressed("add_block"):
			$TileMap.set_cellv(Vector2(mouseXCord, mouseYCord), currentBlock, flipXBlock, flipYBlock)
		if Input.is_action_pressed("del_block"):
			$TileMap.set_cellv(Vector2(mouseXCord, mouseYCord), -1, flipXBlock, flipYBlock)

		if Input.is_action_just_pressed("ui_prev_block"):
			if !((currentBlock - 1) < lowerTileMapBounds):
				currentBlock -= 1
		elif Input.is_action_just_pressed("ui_next_block"):
			if !((currentBlock + 1) > upperTileMapBounds):
				currentBlock += 1
		
		if Input.is_action_just_pressed("ui_rot_lef"):
			if flipXBlock == false:
				flipXBlock = true
			elif flipXBlock == true:
				flipXBlock = false
		if Input.is_action_just_pressed("ui_rot_right"):
			if flipYBlock == false:
				flipYBlock = true
			elif flipYBlock == true:
				flipYBlock = false



func _on_BaseCamp_activateLevel():
	print("activating level")
	genericTurrets = $TileMap.get_used_cells_by_id(GENERIC_TURRET)
	for i in genericTurrets:
		var GenericTurret = genericTurret.instance()
		GenericTurret.position = Vector2(i.x*64.0, i.y*64)
		if $TileMap.is_cell_x_flipped(i.x, i.y) == true:
			GenericTurret.scale.x = -GenericTurret.scale.x
			GenericTurret.position.x += 32
		else:
			GenericTurret.position.x += 32
		if $TileMap.is_cell_y_flipped(i.x, i.y) == true:
			GenericTurret.scale.y = -GenericTurret.scale.y
			GenericTurret.position.y += 48
		else:
			GenericTurret.position.y += 13
		
		GenericTurret.target = NodePath(targets[rand_range(0, targets.size())])
		print("turrets target is: ", GenericTurret.target)
#		GenericTurret.position = Vector2(i.x*64.0+32, i.y*64+13)
		add_child(GenericTurret)


func _on_BaseCamp_playerEntered(player):
	playerEntered = true
	playerMain = player.name

# Intentionely left blank
func _on_BaseCamp_loadSaveFinished():
	pass # Replace with function body.
