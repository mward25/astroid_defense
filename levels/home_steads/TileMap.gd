extends TileMap

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
		return saveDict
# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#	var tileId
#	var position = Vector2()
#	var flipX = false
#	var flipY = false

func save():
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
	
	for i in saveTiles:
		saveTilesDict.append(i.save())
	
	return saveTilesDict

func loadSave(var saveDict):
#	var lowerTileMapBounds = saveDict.lowerBounds
#	var upperTileMapBounds = saveDict.upperBounds
	print(saveDict)
	
	var strSavData = saveDict.get_line()
	print(strSavData.find(name)+1)
	var dataStart =  strSavData.find(name)+name.length()+1
	strSavData = strSavData.substr(dataStart, strSavData.findn("\n", dataStart))
	var tmpSavDat = parse_json(strSavData)
	print(tmpSavDat)
	if tmpSavDat != null:
		for i in tmpSavDat:
	#		print(i.tileId)
			set_cell(i.positionX, i.positionY, i.tileId, i.flipX, i.flipY)
	
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
