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
		if room["roomID"] == InRoom["roomID"]:
			InRoom["Count"] = room["Count"]
			return
	# Add the room if not exist
	avilableRooms.append(room)
	
func remove(ID: String):
	for room in avilableRooms:
		if room and room["roomID"] == ID:	
			avilableRooms.remove_at(avilableRooms.find(room))


# Variables
var address: String 
var port: int = 8910
var exist: bool = false
var roomID: String = ""
var roomName: String = ""
var playerData: Dictionary = {"name" : "", "character": ""}
var server: ENetMultiplayerPeer 
var gameScene: String = ""
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

signal server_found
signal server_removed
signal avilable_rooms_changed

var RoomInfo: Dictionary = {"name": "name", "Count": 0, "roomID":""}
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
var listenPort: int = 8911
var broadcastPort: int = 8912
var run: bool = false
var serverIP: String
var RoomID: String
var serverInfo: PackedScene = preload("res://addons/mpao/server_info.tscn")

@onready var broadCastTimer: Timer = Timer.new()
@onready var LinstenerTimer: Timer = Timer.new()
@export var broadcastAddress: String = "192.168.1.255"



#endregion

#region Network Manager

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
	removePlayer(str(id))
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
func create_players(players):
	
	positions = get_tree().root.get_node(positionsNode).get_children()	
	# Markers indexer
	var i: int = 0
	for player in players:
		# Instantiate new player scene
		var current_player = load(players[player]["character"]).instantiate() 
		## Set player properties	
		current_player.name = str(player)
		#
		## add player to node tree
		get_tree().root.get_node(playersNode).add_child(current_player)
		current_player.global_position = positions[i].global_position
		#
		i += 1

# Buttons Pressed Functions
func createServer() -> bool:
	if multiplayer.has_multiplayer_peer:
		print("Arleady Created Server !")
		
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()
		
	var err = server.create_server(port, MAX_CONNECTIONS)

	
	# If there an error exist
	if err != OK:
		print("Can not host! " + str(err))
		disconnectFromTheServer()
		return false
		
	multiplayer.multiplayer_peer = server
	print("Creating Server Successfully!! Waiting for Players........")
		
	checkName()
	
	playersLoaded += 1
	
	players[1] = playerData

	# Set Room ID
	roomID = str(randi_range(0,9)) +  str(randi_range(0,9)) +  str(randi_range(0,9)) +  str(randi_range(0,9))

	# Broadcast room Data 
	setUpBroadCast()
	
	return true
	
func createClient() -> bool:
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()

	checkAddress()
	checkName()
	
	# Start Listening
	runListener()
	await  get_tree().create_timer(2).timeout
	
		
	for room in avilableRooms:
		if room.IP == address:
			exist = true
	
	if exist:
		# Create the client
		server.create_client(address, port)
		multiplayer.multiplayer_peer = server
		print("Created Client Successfully!")
		return true
	else:
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
	address = str(IP.get_local_addresses()[0])  if address.strip_edges() == "" or address.strip_edges() == "127.0.0.1" else address

func checkName():
	playerData["name"] = "Unknown" if playerData["name"].strip_edges() == "" else playerData["name"]

func disconnectFromTheServer():
	multiplayer.multiplayer_peer = null
	multiplayer.peer_connected.disconnect(playerConnected)
	multiplayer.peer_disconnected.disconnect(playerDisconnected)
	multiplayer.connected_to_server.disconnect(serverConnected)
	multiplayer.server_disconnected.disconnect(serverDisconnected)
	multiplayer.connection_failed.disconnect(connectionFailed)

func returnToMain():
	get_tree().change_scene_to_file("res://addons/mpao/multiplayer_scene.tscn")

func createPlayers():
	if multiplayer.is_server():
		create_players.rpc(players)

func removePlayer(id: String):
	get_tree().root.get_node(gameScene + "/players/" + id).queue_free()
	
func Set(GameScene: String, PlayersNode: String, PositionsNode: String):
	gameScene = GameScene
	playersNode = PlayersNode
	positionsNode = PositionsNode
#endregion

#region Lan Server Browser

func _ready():
	
	broadCastTimer.connect("timeout", _on_broad_cast_timer_timeout)
	LinstenerTimer.connect("timeout", _on_listener_timer_timeout)
	broadCastTimer.wait_time = 1
	LinstenerTimer.wait_time = 1
	
	
	call_deferred("add_child", broadCastTimer)
	call_deferred("add_child", LinstenerTimer)

# Broad cast room data to all devices on LAN
func setUpBroadCast():
	RoomInfo.name = roomName if roomName else "Unknown"
	RoomInfo.Count = playersLoaded
	RoomInfo.roomID = roomID
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
	LinstenerTimer.stop()
	broadCastTimer.stop()
	
	if broadcaster != null:
		broadcaster.close()

# Set up listener
func setUp():
	if !listener:
		listener = PacketPeerUDP.new()
		var err = listener.bind(listenPort)
		if err == OK:
			print("Bound to listen port " + str(listenPort) + " Successful")
		else:
			print("Faild to bind to listen port!")	
	else:
		print("Already Lestening!")
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
			RoomID = roomInfo.roomID
			if serverIP != "":
				add(Dictionary({"Name": roomInfo.name, "IP": serverIP, "Count": roomInfo.Count, "roomID": roomInfo.roomID}))
		else:
			remove(RoomID)
			
	add_server_info()

func add_server_info():
	if get_tree().root.has_node("multiplayerScene"):
		if avilableRooms:
			for room in avilableRooms:
				for i in get_tree().root.get_node("multiplayerScene/LanServerBrowser/Panel/ScrollContainer/ServerInfos").get_children():
					if i.name == room.roomID:
						i.get_node("PlayersCount").text = str(room.Count)
						return
						
				var currentInfo = serverInfo.instantiate()
				currentInfo.name = room.roomID
				currentInfo.get_node("Name").text = room.Name
				currentInfo.get_node("IP").text = serverIP
				currentInfo.get_node("PlayersCount").text = str(room.Count)
				currentInfo.get_node("ID").text = str(room.roomID)
				currentInfo.connect("Join", joinByIp)
				get_tree().root.get_node("multiplayerScene/LanServerBrowser/Panel/ScrollContainer/ServerInfos").add_child(currentInfo)
		else:
			for i in get_tree().root.get_node("multiplayerScene/LanServerBrowser/Panel/ScrollContainer/ServerInfos").get_children():
				i.queue_free()

func joinByIp(ip):
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()

	checkAddress()

	# Create the client
	var err = server.create_client(ip, port)
	multiplayer.multiplayer_peer = server
	print("Created Client Successfully!")

	# If there an error exist
	if err != OK:
		print("Can not host! " + str(err))
		disconnectFromTheServer()
		return false
	
	playerData["name"] = get_tree().root.get_node("multiplayerScene/LanServerBrowser/HBoxContainer/Name").text
	playerData["character"] = "res://player.tscn"
	
	get_tree().root.get_node("multiplayerScene/LanServerBrowser").hide()
	get_tree().root.get_node("multiplayerScene/lobby").show()
	get_tree().root.get_node("multiplayerScene/toggle").hide()
	

#endregion

