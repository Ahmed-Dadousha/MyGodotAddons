@tool
extends EditorPlugin

const FOLDERS: Array[String] = ["Scenes", "Scripts", "Assets", "Assets/Arts", "Assets/Sounds", 
								"Assets/Fonts", "Scenes/Levels", "Scenes/Characters", "Scenes/Objects",
								 "Scenes/UI", "Scenes/Enemies"]

func _enter_tree():
	# Initialization of the plugin goes here.
	for folder in FOLDERS:
		if !DirAccess.dir_exists_absolute("res://" + folder):
			DirAccess.make_dir_absolute("res://" + folder)

func _exit_tree():
	# Clean-up of the plugin goes here.
	pass
