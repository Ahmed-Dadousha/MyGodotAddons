@tool
extends EditorPlugin

const AUTOLOAD_NAME = "NetworkManager"

var file_exists: bool
var file: FileAccess


func _enter_tree():
	# Initialization of the plugin goes here.
	# Add Network Manager to Autoload
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/mpao/NetworkManager.gd")
	

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_autoload_singleton(AUTOLOAD_NAME)

