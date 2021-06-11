extends Node2D
var mousePos = Vector2(0,0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$TileMap.tile_set = preload("res://my_assets/retro_tilemap/retro_tileset.tres")
#	$TileMap.set_cellv(Vector2(0, 0), 0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MouseCurser.position = get_global_mouse_position()
	if Input.is_action_pressed("ui_select"):
		$TileMap.set_cellv(Vector2(get_global_mouse_position().x/64.0, get_global_mouse_position().y/64.0-1), 0)
	if Input.is_action_pressed("ui_deselect"):
		$TileMap.set_cellv(Vector2(get_global_mouse_position().x/64.0, get_global_mouse_position().y/64.0-1), -1)

func _input(event):
	if event is InputEventMouseMotion:
		mousePos = event.position
#		print(mousePos)
