extends Node

#region Game Manager 


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
	
var avilableRooms: Array[Dictionary] = []

func add(room: Dictionary):
	# If room exist in avilable rooms update it's players count
	for InRoom in avilableRooms:
		if room["Name"] == InRoom["Name"]:
			InRoom["Count"] = room["Count"]
			return
	# Add the room if not exist
	avilableRooms.append(room)
	
func remove(Name: String):
	for room in avilableRooms:
		if room and room["Name"] == Name:	
			avilableRooms.remove_at(avilableRooms.find(room))

#endregion

#region Network Manager

# Variables
var address: String 
var port: int = 8910
var playerData: Dictionary = {"name" : "", "color": Color(0,0,0,0)}
var server: ENetMultiplayerPeer 
var multiplayerScene:String = ""
var gameScene: String = ""
var playerScene: PackedScene
var playersNode: String = ""
var positionsNode: String = ""

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
			players.clear()
			playersLoaded = 0
			connected = false

# Multiplayer Functions

# Server Functions
func playerConnected(id):
	print("Player " + str(id) + " Connected")
	playersLoaded += 1
	checkName()
	register_player.rpc_id(id, playerData)	
	player_connected.emit(id, playerData)
	
func playerDisconnected(id):
	# Remove the player data if disconnected
	players.erase(id)
	playersLoaded -= 1
	print("Player " + str(id) + " Disconnected")
	player_disconnected.emit(id)
	
# Client Functions
func serverConnected():
	playersLoaded += 1
	print("Server Connected!")
	checkName()
	# add player data to players array
	players[multiplayer.get_unique_id()] = playerData
	connected = true

func serverDisconnected():
	print("Server Disconnected!")
	multiplayer.multiplayer_peer = null
	players.clear()
	playersLoaded = 0
	server_disconnected.emit()
	returnToMain()
	
func connectionFailed():
	print("Couldn't connect!")	
	multiplayer.multiplayer_peer = null

# RPC Functions
@rpc("any_peer", "call_local", "reliable")
func register_player(newPlayerData):
	var newPlayerId = multiplayer.get_remote_sender_id()
	players[newPlayerId] = newPlayerData
	
@rpc("any_peer", "call_local")
func startGame():
	get_tree().change_scene_to_file(gameScene)

@rpc("any_peer", "call_local")
func removePlayer(id: int):
	get_node(str(id)).queue_free()

@rpc("any_peer", "call_local")	
func create_players(players):
	
	positions = get_tree().root.get_node(positionsNode).get_children()	
	# Markers indexer
	var i: int = 0
	
	for player in players:
		# Instantiate new player scene
		var current_player = playerScene.instantiate() as CharacterBody2D
		# Set player properties
		current_player.name = str(player)
		current_player.modulate = players[player]["color"]
		
		# add player to node tree
		get_tree().root.get_node(playersNode).add_child(current_player)
		current_player.NetworkManager_position = positions[i].NetworkManager_position
		
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
	
	playersLoaded += 1
	
	players[1] = playerData
	
	
	# Broadcast room Data 
	setUpBroadCast()
	
	return true
	
func createClient() -> bool:
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()

	checkAddress()
	checkName()
	checkColor()
	
	# Start Listening
	runListener()
	await  get_tree().create_timer(2).timeout
	
		
	for room in avilableRooms:
		if room.IP == address:
			break
	
	# Create the client
	server.create_client(address, port)
	multiplayer.multiplayer_peer = server
	print("Created Client Successfully!")

	return true


	print("This IP Not Exist")
	disconnectFromTheServer()
	return false
	
func Start():
	startGame.rpc()

# My Custem Functions
func printPlayersData():
	print("\nThere Is [" + str(playersLoaded) + "] Players\n")
	
	for player in players.keys():
		print(players[player])
		
	print("\n")

func multiplayerFunc():
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.connected_to_server.connect(serverConnected)
	multiplayer.server_disconnected.connect(serverDisconnected)
	multiplayer.connection_failed.connect(connectionFailed)

func checkAddress():
	# To check if it is null
	address = "192.168.1.2" if address.strip_edges() == "" or  address.strip_edges() == "127.0.0.1" else address

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

func Set(MultiplayerScene: String, GameScene: String, PlayerScene: PackedScene, PlayersNode: String, PositionsNode: String):
	multiplayerScene = MultiplayerScene
	gameScene = GameScene
	playerScene = PlayerScene
	playersNode = PlayersNode
	positionsNode = PositionsNode
#endregion

#region Lan Server Browser
signal server_found
signal server_removed
signal avilable_rooms_changed

var RoomInfo: Dictionary = {"name": "name", "Count": 0}
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
var listenPort: int = 8911
var broadcastPort: int = 8912
var run: bool = false
var serverIP: String
var roomName: String
var serverInfo: PackedScene = preload("res://addons/mpao/server_info.tscn")

@onready var broadCastTimer: Timer = Timer.new()
@onready var LinstenerTimer: Timer = Timer.new()
@export var broadcastAddress: String = "192.168.1.255"


func _ready():
	
	broadCastTimer.connect("timeout", _on_broad_cast_timer_timeout)
	LinstenerTimer.connect("timeout", _on_listener_timer_timeout)
	broadCastTimer.wait_time = 1
	LinstenerTimer.wait_time = 1
	
	
	call_deferred("add_child", broadCastTimer)
	call_deferred("add_child", LinstenerTimer)

# Broad cast room data to all devices on LAN
func setUpBroadCast():
	RoomInfo.name = players[multiplayer.get_unique_id()].name
	RoomInfo.Count = playersLoaded
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcastAddress, listenPort)
	var err = broadcaster.bind(broadcastPort)
	
	if err == OK:
		print("Bound to Broadcast Port " + str(listenPort) + " Successful!")
	else:
		print("Faild to bind to broadcast port!")
	
	broadCastTimer.start()

# Stop Broadcasting & Listening
func cleanUp():
	if listener:
		listener.close()
	
	broadCastTimer.stop()
	
	if broadcaster != null:
		broadcaster.close()

# Set up listener
func setUp():
	listener = PacketPeerUDP.new()
	var err = listener.bind(listenPort)
	if err == OK:
		print("Bound to listen port " + str(listenPort) + " Successful")
	else:
		print("Faild to bind to listen port!")	

#
func runListener():
	setUp()
	run = true
	LinstenerTimer.start()

# Brocast room data every one Second
func _on_broad_cast_timer_timeout():
	RoomInfo.Count = playersLoaded
	var data = JSON.stringify(RoomInfo)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)

func _on_listener_timer_timeout():
	if run == true:
		
		serverIP = listener.get_packet_ip()
		var serverPort = listener.get_packet_port()

		if listener.get_available_packet_count() > 0:
			var bytes = listener.get_packet()	
			var data = bytes.get_string_from_ascii()
			var roomInfo = JSON.parse_string(data)
			roomName = roomInfo.name
			if serverIP != "":
				add(Dictionary({"Name": roomInfo.name, "IP": serverIP, "Count": roomInfo.Count}))
		else:
			remove(roomName)
			
	add_server_info()

func add_server_info():
	if avilableRooms:
		for room in avilableRooms:
			for i in get_tree().root.get_node("multiplayerScene/LanServerBrowser/Panel/ScrollContainer/ServerInfos").get_children():
				if i.name == room.Name:
					i.get_node("IP").text = serverIP
					i.get_node("PlayersCount").text = str(room.Count)
					return
					
			var currentInfo = serverInfo.instantiate()
			currentInfo.name = room.Name
			currentInfo.get_node("Name").text = room.Name
			currentInfo.get_node("IP").text = serverIP
			currentInfo.get_node("PlayersCount").text = str(room.Count)
			currentInfo.connect("Join", joinByIp)
			get_tree().root.get_node("multiplayerScene/LanServerBrowser/Panel/ScrollContainer/ServerInfos").add_child(currentInfo)
	else:
		for i in get_tree().root.get_node("multiplayerScene/LanServerBrowser/Panel/ScrollContainer/ServerInfos").get_children():
			i.queue_free()

func joinByIp(ip):
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()

	checkAddress()
	checkName()
	
	# Create the client
	server.create_client(ip, port)
	multiplayer.multiplayer_peer = server
	print("Created Client Successfully!")
	
	get_tree().root.get_node("multiplayerScene/LanServerBrowser").hide()
	get_tree().root.get_node("multiplayerScene/lobby").show()
	

#endregion

