extends Control

@export var playerScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkManager.connect("countChanged", change_count)
	NetworkManager.Set("res://game.tscn", playerScene, "game/players", "game/spawnPos")

func _on_client_pressed():

	set_player_data()
	if await NetworkManager.createClient():
		$main.hide()
		$lobby.show()
		$toggle.hide()
	else:
		$Popup.show()
		
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
	NetworkManager.address = $main/IP.text

func clear():
	NetworkManager.disconnectFromTheServer()
	NetworkManager.playersLoaded = 0
	NetworkManager.players.clear()

func _on_check_button_pressed():
	$main.visible = !$main.visible 
	$LanServerBrowser.visible = !$LanServerBrowser.visible
	
func _on_server_pressed():
	NetworkManager.roomName = $LanServerBrowser/HBoxContainer/Name.text
	if NetworkManager.createServer():
		$LanServerBrowser.hide()
		$toggle.hide()
		$lobby.show()

func _on_refresh_pressed():
	NetworkManager.runListener()


func _on_ok_pressed():
	$Popup.hide()
