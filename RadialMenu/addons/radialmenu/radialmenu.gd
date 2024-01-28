@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("RadialMenu","Control",preload("res://addons/radialmenu/RadialMenu.gd"), preload("res://addons/radialmenu/Icon.png"))


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("RadialMenu")
