extends  Node2D

#MAPO
signal countChanged()
signal sceneChanged()

var changeScene:bool = false:
	set(value):
		changeScene = true
		sceneChanged.emit()

var players: Dictionary = {}

var playersLoaded: int = 0:
	set(value):
		playersLoaded = value
		countChanged.emit()
	
var avilableRooms: Array = []

func addIP(value):
	if value not in avilableRooms:
		avilableRooms.append(value)

func removeIP(value):
	avilableRooms.erase(value)

