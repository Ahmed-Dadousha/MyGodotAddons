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

- In the game or level scene create a node contains some markers 2d as spawn positions for  players and a node to contain the players.

- Set Multiplayer Scene, Game Scene, Player Scene, Positions Node, Players Node: <br>
	`NetworkManager.Set("Your Multiplayer Scene as string", "Your Game Scene as string", "Your Player Scene as Packed Scene", "Your Positions Node Path In Game Scene as String", "Your Players Node Path In Game Scene As String")`

- Assign Player Data, IP Both In Server & Clients.

- Create A Server: <br>
	`if NetworkManger.createServer():`<br>
	#Code here

- Create A Client: <br>
	`if await NetworkManger.createClient():`<br>
	#Code here

- To avoid control other players character Add next code to player script:<br>

	#To avoid control other players character <br>
	`func _enter_tree():`<br>
	`set_multiplayer_authority(str(name).to_int())`<br><br>
	#Add nextLine in process function in player script before any other code <br> 
   	`if not is_multiplayer_authority(): return`

- To Create players in `_ready() `function call: <br>
	`NetworkManager.createPlayers()`

- To Start the game: <br>
	`NetworkManager.Start()`