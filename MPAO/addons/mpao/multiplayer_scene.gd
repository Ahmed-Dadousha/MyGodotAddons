extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkManager.connect("countChanged", change_count)

func _on_client_pressed():

	NetworkManager.address = $main/IP.text
	NetworkManager.playerData["name"] = $main/Name.text
	if await NetworkManager.createClient():
		$main.hide()
		$lobby.show()
		$toggle.hide()
	else:
		$Popup.show()
			
func _on_exit_pressed():
	clear()
	$lobby.hide()
	$LanServerBrowser.show()
	$lobby/Start.hide()
	NetworkManager.cleanUp()
	$toggle.show()
	$lobby/Start.hide()
	
func _on_start_pressed():
	NetworkManager.Start()
	NetworkManager.cleanUp()
	
func change_count():
	$lobby/playersCount.text = str(NetworkManager.playersLoaded)

func _on_data_pressed():
	NetworkManager.printPlayersData()

func clear():
	NetworkManager.disconnectFromTheServer()
	NetworkManager.playersLoaded = 0
	NetworkManager.players.clear()

func _on_check_button_pressed():
	$main.visible = !$main.visible 
	$LanServerBrowser.visible = !$LanServerBrowser.visible
	
func _on_server_pressed():
	NetworkManager.roomName = $LanServerBrowser/HBoxContainer/Name.text
	NetworkManager.playerData["name"] = $LanServerBrowser/HBoxContainer/Name.text
	if NetworkManager.createServer():
		$LanServerBrowser.hide()
		$toggle.hide()
		$lobby.show()
		$lobby/Start.show()
		
func _on_refresh_pressed():
	NetworkManager.runListener()

func _on_ok_pressed():
	$Popup.hide()
