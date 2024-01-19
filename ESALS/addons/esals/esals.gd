@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("Saver","res://addons/esals/sl.gd" )


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_autoload_singleton("Saver")
