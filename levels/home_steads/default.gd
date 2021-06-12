extends Node2D
var currentBlock = 0
var flipXBlock = false
var flipYBlock = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$TileMap.tile_set = preload("res://my_assets/retro_tilemap/retro_tileset.tres")
#	$TileMap.set_cellv(Vector2(0, 0), 0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MouseCurser.position = Vector2(get_global_mouse_position().x, get_global_mouse_position().y)
	if Input.is_action_pressed("ui_select"):
		$TileMap.set_cellv(Vector2(get_global_mouse_position().x/64.0, get_global_mouse_position().y/64.0), currentBlock, flipXBlock, flipYBlock)
	if Input.is_action_pressed("ui_deselect"):
		$TileMap.set_cellv(Vector2(get_global_mouse_position().x/64.0, get_global_mouse_position().y/64.0), -1, flipXBlock, flipYBlock)

	if Input.is_action_just_pressed("ui_prev_block"):
		currentBlock -= 1
	elif Input.is_action_just_pressed("ui_next_block"):
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

