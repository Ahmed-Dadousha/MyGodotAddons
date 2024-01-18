extends Node

#region Multiplayer Manager

# Variables
var address: String 
var port: int = 8910
var playerData: Dictionary = {"name" : "", "color": Color(0,0,0,0), "index": 0}
var server: ENetMultiplayerPeer 
var mainScene:String = ""
var NextScene: String = ""
# Constants
const MAX_CONNECTIONS = 20

# Signals
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal connection_faild

var connected: bool = false


# Node Functions

#func _process(_delta):
	#if connected == true:
		#if multiplayer.multiplayer_peer == null:
			#GameManager.players.clear()
			#GameManager.playersLoaded = 0
			#connected = false





#endregion
