extends Node

#region NetworkManager 


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

#endregion


#region Multiplayer Manager

# Variables
var address: String 
var port: int = 8910
var playerData: Dictionary = {"name" : "", "color": Color(0,0,0,0)}
var server: ENetMultiplayerPeer 
var multiplayerScene:String = ""
var gameScene: String = ""
var playerScene: PackedScene
# Constants
const MAX_CONNECTIONS = 20

# Signals
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal connection_faild

var connected: bool = false

@onready var positions: Array[Node]

# Node Functions

func _process(_delta):
	if connected == true:
		if multiplayer.multiplayer_peer == null:
			NetworkManager.players.clear()
			NetworkManager.playersLoaded = 0
			connected = false

# Multiplayer Functions

# Server Functions
func playerConnected(id):
	print("Player " + str(id) + " Connected")
	NetworkManager.playersLoaded += 1
	checkName()
	register_player.rpc_id(id, playerData)	
	player_connected.emit(id, playerData)
	
func playerDisconnected(id):
	# Remove the player data if disconnected
	NetworkManager.players.erase(id)
	NetworkManager.playersLoaded -= 1
	print("Player " + str(id) + " Disconnected")
	player_disconnected.emit(id)
	
# Client Functions
func serverConnected():
	NetworkManager.playersLoaded += 1
	print("Server Connected!")
	checkName()
	# add player data to players array
	NetworkManager.players[multiplayer.get_unique_id()] = playerData
	connected = true

func serverDisconnected():
	print("Server Disconnected!")
	multiplayer.multiplayer_peer = null
	NetworkManager.players.clear()
	NetworkManager.playersLoaded = 0
	server_disconnected.emit()
	returnToMain()
	
func connectionFailed():
	print("Couldn't connect!")	
	multiplayer.multiplayer_peer = null

# RPC Functions
@rpc("any_peer", "call_local", "reliable")
func register_player(newPlayerData):
	var newPlayerId = multiplayer.get_remote_sender_id()
	NetworkManager.players[newPlayerId] = newPlayerData
	
@rpc("any_peer", "call_local")
func startGame():
	get_tree().change_scene_to_file(gameScene)

@rpc("any_peer", "call_local")
func removePlayer(id: int):
	get_node(str(id)).queue_free()

@rpc("any_peer", "call_local")	
func create_players(players):
	
	positions = get_tree().root.get_node("game/spawnPos").get_children()	
	# Markers indexer
	var i: int = 0
	
	for player in players:
		# Instantiate new player scene
		var current_player = playerScene.instantiate() as CharacterBody2D
		# Set player properties
		current_player.name = str(player)
		current_player.modulate = players[player]["color"]
		
		# add player to node tree
		get_tree().root.get_node("game/players").add_child(current_player)
		current_player.global_position = positions[i].global_position
		
		i += 1

# Buttons Pressed Functions
func createServer() -> bool:
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()
		
	var err = server.create_server(port, MAX_CONNECTIONS)


	# If there an error exist
	if err != OK:
		print("Can not host! " + str(err))
		return false
		
	multiplayer.multiplayer_peer = server
	print("Creating Server Successfully!! Waiting for Players........")
		
	checkName()
	checkColor()
	
	NetworkManager.playersLoaded += 1
	
	NetworkManager.players[1] = playerData
	
	
	# Broadcast room Data 
	#setUpBroadCast(playerData["name"])
	
	return true
	
func createClient() -> bool:
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()

	checkAddress()
	checkName()
	checkColor()
	# Start Listening
	#runListener()
	#await  get_tree().create_timer(2).timeout
	#
	#if address not in NetworkManager.avilableRooms:
		#print(NetworkManager.avilableRooms)
		#print("This IP Not Exist")
		#disconnectFromTheServer()
		#return false
		
	# Create the client
	server.create_client(address, port)
	multiplayer.multiplayer_peer = server
	print("Created Client Successfully!")

	return true

func Start():
	startGame.rpc()

# My Custem Functions
func printPlayersData():
	print("\nThere Is [" + str(NetworkManager.playersLoaded) + "] Players\n")
	
	for player in NetworkManager.players.keys():
		print(NetworkManager.players[player])
		
	print("\n")

func multiplayerFunc():
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.connected_to_server.connect(serverConnected)
	multiplayer.server_disconnected.connect(serverDisconnected)
	multiplayer.connection_failed.connect(connectionFailed)

func checkAddress():
	# To check if it is null
	address = "127.0.0.1" if address.strip_edges() == "" else address

func checkName():
	playerData["name"] = "Unknown" if playerData["name"].strip_edges() == "" else playerData["name"]

func checkColor():
	playerData["color"] = Color(0,0,0,1) if playerData["color"] == Color(0,0,0,0)  else  playerData["color"]

func disconnectFromTheServer():
	multiplayer.multiplayer_peer = null
	multiplayer.peer_connected.disconnect(playerConnected)
	multiplayer.peer_disconnected.disconnect(playerDisconnected)
	multiplayer.connected_to_server.disconnect(serverConnected)
	multiplayer.server_disconnected.disconnect(serverDisconnected)
	multiplayer.connection_failed.disconnect(connectionFailed)

func returnToMain():
	get_tree().change_scene_to_file(multiplayerScene)

func createPlayers():
	if multiplayer.is_server():
		create_players.rpc(players)
#endregion
