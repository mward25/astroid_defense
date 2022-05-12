extends TileMap

var SaveDataBase
var pathToDataBase = "user://save.db"
onready var tableName = get_parent().name




class TileMiniSave:
	var tileId = 1
	var position = Vector2()
	var flipX = false
	var flipY = false
	
	func save():
		var saveDict = {
			"tileId": tileId,
			"positionX": position.x,
			"positionY": position.y,
			"flipX": flipX,
			"flipY": flipY
		}
		
		
		
		
		return saveDict.duplicate(true)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func ready():
	pass
#	var tileId
#	var position = Vector2()
#	var flipX = false
#	var flipY = false

func save():
	var saveTilesDataBaseDict : Dictionary
	
	var saveTiles = []
	var saveTilesDict = []
	var lowerTileMapBounds = get_parent().lowerTileMapBounds
	var upperTileMapBounds =  get_parent().upperTileMapBounds
	
	for i in upperTileMapBounds+1:
		print("saving id ", i)
		var tilePositions = get_used_cells_by_id(i)
		var locationsInTileMap = 0
		for j in tilePositions:
			var currentTile = TileMiniSave.new()
			currentTile.tileId = i
			currentTile.position = tilePositions[locationsInTileMap]
			
			currentTile.flipX = is_cell_x_flipped(currentTile.position.x, currentTile.position.y)
			currentTile.flipY = is_cell_y_flipped(currentTile.position.x, currentTile.position.y)
			
			saveTiles.append(currentTile)
			locationsInTileMap += 1
			print("saving tile at position ", currentTile.position)
	
	
	
	# if true is used so that j will be removed when we are done with it
	if true:
		var j = 0
		for i in saveTiles:
			if j == 0:
				saveTilesDataBaseDict["tiles"] = {j:i.save()}
			else:
				(saveTilesDataBaseDict["tiles"])[String(j)] = i.save()
			j += 1
		
		if j == 0:
			saveTilesDataBaseDict["tiles"] = {}
	
	print(saveTilesDataBaseDict)
	return saveTilesDataBaseDict.duplicate(true)

func loadSave(var saveDict):
#	var lowerTileMapBounds = saveDict.lowerBounds
#	var upperTileMapBounds = saveDict.upperBounds
	print(saveDict)
	var saveTilesDict = saveDict["tiles"]
	if saveDict != null:
		for i in saveTilesDict:
			var currentTile = saveTilesDict[i]
			set_cell(currentTile.positionX, currentTile.positionY, currentTile.tileId, currentTile.flipX, currentTile.flipY)
	
	
#	for i in saveDict.tilePosisions:
#		set_cellv(i.position, i.tileId, i.flipX, i.flipY)

#func getTileImage(tileId):
#	if tileId == 0:
#		return "res://my_assets/retro_tilemap/build/dark_floor_with_vine.png"
#	elif tileId == 1:
#


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
