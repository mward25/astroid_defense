extends Node2D
const GENERIC_TURRET = 2
var currentBlock = 0
export (Array) var targets = []

signal activateLevel

onready var upperTileMapBounds = $TileMap.tile_set.get_tiles_ids().max()
onready var lowerTileMapBounds = $TileMap.tile_set.get_tiles_ids().min()

onready var genericTurrets = $TileMap.get_used_cells_by_id(2)
var genericTurret = preload("res://objects/defence/turrets/generic_turret.tscn")

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
# Called when the node enters the scene tree for the first time.
func _ready():
	addMyPlayer()
	$TileMap.tile_set = preload("res://my_assets/retro_tilemap/retro_tileset.tres")
#	print("upper: ", upperTileMapBounds, "\nlower: ", lowerTileMapBounds)
#	$TileMap.set_cellv(Vector2(0, 0), 0)
	

func save():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var saveNodes = get_tree().get_nodes_in_group("persist")
	
	for i in saveNodes:
		var saveData = i.save()
		print(saveData)
		for j in saveData:
			save_game.store_string(to_json(saveData))

func loadSave():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.READ)
	var saveNodes = get_tree().get_nodes_in_group("persist")
#	var saveData = parse_json(str(save_game))
	for i in saveNodes:
		i.loadSave(save_game)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
#		GenericTurret.position = Vector2(i.x*64.0+32, i.y*64+13)
		add_child(GenericTurret)
