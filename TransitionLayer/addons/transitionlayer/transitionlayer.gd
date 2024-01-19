@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_autoload_singleton("TransitionLayer","res://addons/transitionlayer/transition_layer.tscn" )


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_autoload_singleton("TransitionLayer")
