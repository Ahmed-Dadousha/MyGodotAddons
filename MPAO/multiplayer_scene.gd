extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkManager.connect("countChanged", change_count)
	NetworkManager.multiplayerScene = "res://multiplayer_scene.tscn"
	NetworkManager.gameScene = "res://game.tscn"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_server_pressed():
	
	set_player_data()
	if NetworkManager.createServer():
		$main.hide()
		$lobby.show()
		$lobby/Start.show()

func _on_client_pressed():

	set_player_data()
	if NetworkManager.createClient():
		$main.hide()
		$lobby.show()
	
func _on_exit_pressed():
	NetworkManager.disconnectFromTheServer()
	
	NetworkManager.playersLoaded = 0
	NetworkManager.players.clear()
	
	$lobby.hide()
	$main.show()
	$lobby/Start.hide()

func _on_start_pressed():
	NetworkManager.startGame.rpc()

func change_count():
	$lobby/playersCount.text = str(NetworkManager.playersLoaded)

func _on_data_pressed():
	NetworkManager.printPlayersData()

func set_player_data():
	NetworkManager.playerData["name"] = $main/Name.text
	NetworkManager.playerData["color"] = $main/ColorPickerButton.color
	NetworkManager.address = $main/IP.text
