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

- Set Game Scene,Positions Node, Players Node: <br>
	`NetworkManager.Set("Your Game Scene as string","Your Positions Node Path In Game Scene as String", "Your Players Node Path In Game Scene As String")`

- Add this code before any code in player script:<br>

	#To avoid control other players character <br>
	`func _enter_tree():`<br>
	`set_multiplayer_authority(str(name).to_int())`<br><br>
	#Add nextLine in process function in player script before any other code <br> 
   	`if not is_multiplayer_authority(): return`

- To Create players in `_ready() `function call: <br>
	`NetworkManager.createPlayers()`

- Set player character: <br>
	`NetworkManager.playerData["character"] = "Your character Scene as string`
