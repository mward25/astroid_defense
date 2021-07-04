extends ItemList


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var shipList = $"/root/CurrentShip".shipList
	max_columns = shipList.size()
	print(shipList.size())
	for i in $"/root/CurrentShip".shipList:
		var tmpPlayer = load(shipList[i]).instance()
		var tmpPlayerAnimPlayer
		print("test output: ")
		
		add_item(i)
		ensure_current_is_visible()
		print("adding item ", i)
	
	for i in get_item_count():
		print("item ", i , " is ", get_item_text(i))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
