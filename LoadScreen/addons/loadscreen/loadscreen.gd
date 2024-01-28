@tool
extends EditorPlugin


func _enter_tree():
	if FileAccess.file_exists("res://addons/loadscreen/load_screen.tscn"):
		add_autoload_singleton("loadScreen","res://addons/loadscreen/load_screen.tscn")


func _exit_tree():
	remove_autoload_singleton("loadScreen")
