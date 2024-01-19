extends Node2D

@export var playerScene: PackedScene
@onready var positions: Array[Node]
# Called when the node enters the scene tree for the first time.
func _ready():
	
	if multiplayer.get_unique_id() == 1:
		create_players.rpc()

@rpc("any_peer", "call_local")	
func create_players():
	
	positions = get_tree().get_nodes_in_group("pos")
	
	# Markers indexer
	var i: int = 0
	
	for player in NetworkManager.players:
		# Instantiate new player scene
		var current_player = playerScene.instantiate() as CharacterBody2D
		# Set player properties
		current_player.name = str(player)
		current_player.modulate = NetworkManager.players[player]["color"]
		
		# add player to node tree
		get_node("players").add_child(current_player)
		
		current_player.global_position = positions[i].global_position
		
		i += 1
