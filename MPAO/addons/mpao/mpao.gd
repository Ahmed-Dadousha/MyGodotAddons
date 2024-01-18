@tool
extends EditorPlugin

const AUTOLOAD_NAME = "NetworkManager"
const GAME_MANAGER = "res://Scripts/GameManager.gd"

var file_exists: bool
var file: FileAccess
var GameManager_Variables = """extends Node
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

"""
var init:bool = false

func _enter_tree():
	# Initialization of the plugin goes here.
	# Add Network Manager to Autoload
	add_autoload_singleton(AUTOLOAD_NAME,"res://addons/mpao/mpao.gd")
	
	# If Scripts folder does not exist creat it
	if !DirAccess.dir_exists_absolute("res://Scripts"):
		DirAccess.make_dir_absolute("res://Scripts")
	
	# If GameManager script does not exist
	if !FileAccess.file_exists("res://Scripts/GameManager.gd") :
		# Create Mode
		file = FileAccess.open(GAME_MANAGER, FileAccess.WRITE)
	
	else:
		 #Append Mode
		file = FileAccess.open(GAME_MANAGER, FileAccess.READ_WRITE) 
		var file_data = file.get_as_text()
		
		if "#MAPO" in file_data:
			return
		## Move the curser to end of the file
		file.seek_end()
		#
		GameManager_Variables = GameManager_Variables.erase(0,12)

	# If error can not create the file
	if file == null:
		print(FileAccess.get_open_error())
		return	

	# Write Data to the file	
	file.store_string(GameManager_Variables)
	
	# Close the file
	file.close()
	
	# Add GameManager To Autoload
	add_autoload_singleton("GameManager","res://Scripts/GameManager.gd")

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_autoload_singleton(AUTOLOAD_NAME)
	remove_autoload_singleton("GameManager")

