# MultiPlayer Addon

## Introduction
Add the multiplayer functionality to your project
	

## Technologies

- Godot 4.2.

## Features

	
	

## Setup

- Put the addon in addons folder.

## Usage

- Enable the plugin.
- Set Multiplayer Scene &  Game Scene & Player Scene: <br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NetworkManager.multiplayerScene = "Your Multiplayer scene"<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NetworkManager.gameScene = "Your main Game scene" <br> NetworkManager.playerScene = #Your player scene


- Assign Player Data, Ip In Server & Clients.
- Create A Server: <br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if NetworkManger.createServer(): <br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Code here
- Create A Client: <br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if await NetworkManger.createClient():<br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Code here
-
- To avoid control other players character Add next code to player script:<br>

	#To avoid control other players character <br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;func _enter_tree():<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;set_multiplayer_authority(str(name).to_int())<br><br>
	#Add nextLine in process function in player script before any other code <br> 
   	if not is_multiplayer_authority(): return
