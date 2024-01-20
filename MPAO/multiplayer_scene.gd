extends Control

@export var playerScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkManager.connect("countChanged", change_count)
	NetworkManager.Set("res://multiplayer_scene.tscn", "res://game.tscn", playerScene, "game/players", "game/spawnPos")

func _on_server_pressed():
	
	set_player_data()
	if NetworkManager.createServer():
		$main.hide()
		$lobby.show()
		$lobby/Start.show()
		$toggle.hide()

func _on_client_pressed():

	set_player_data()
	if await NetworkManager.createClient():
		$main.hide()
		$lobby.show()
	
func _on_exit_pressed():

	clear()
	$lobby.hide()
	$main.show()
	$lobby/Start.hide()
	NetworkManager.cleanUp()
	$toggle.show()

func _on_start_pressed():
	NetworkManager.Start()
	NetworkManager.cleanUp()
	
func change_count():
	$lobby/playersCount.text = str(NetworkManager.playersLoaded)

func _on_data_pressed():
	NetworkManager.printPlayersData()

func set_player_data():
	NetworkManager.playerData["name"] = $main/Name.text
	NetworkManager.playerData["color"] = $main/ColorPickerButton.color
	NetworkManager.address = $main/IP.text

func clear():
	NetworkManager.disconnectFromTheServer()
	NetworkManager.playersLoaded = 0
	NetworkManager.players.clear()

func _on_check_button_pressed():
	$main.visible = !$main.visible 
	$LanServerBrowser.visible = !$LanServerBrowser.visible
	
	if $LanServerBrowser.visible:
		NetworkManager.runListener()
