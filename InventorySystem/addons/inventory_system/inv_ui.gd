@tool
extends Control

@export var Inv: Array[InvItem]
@export var InventoryBG: Texture2D
@export var InventorySlotBG: Texture2D
@onready var slots = $BG/GridContainer.get_children()
var MAX_SLOTS_SIZE: int = 16


func _ready():
	visible = false
	$BG.texture = InventoryBG if InventoryBG else preload("res://addons/inventory_system/inventory-slot.png")
	
	for slot in slots:
		slot.get_node("BG").texture = InventorySlotBG if InventorySlotBG else preload("res://addons/inventory_system/inventory-slot.png")

func addItem(newItem: Dictionary):
	
	# If new Item already exist in the Inventory update it's count. 
	for item in Inv:
		if item.name == newItem.name:
			item.count += 1
			print("Increased Count Successfully!")
			
			for slot in slots:
				if slot.data().icon == item.texture:
					slot.update(item.count)
			return
	
	# Else add it to the inventory.
	# Create a new InvItem Resource variable
	var item = InvItem.new()
	# Set it's texture and name 
	item.name = newItem.name
	item.texture = load(newItem.icon)
	item.count += 1

	
	for slot in slots:
		if !slot.data().icon:
			# Add it to the Inventory
			slot.insert(item)
			Inv.append(item)
			print("Added Succeffully!")
			return
	print("Inventory is Full!")

func removeItem(oldItemName: String):
	for item in Inv:
		if item.name == oldItemName:
			Inv.erase(item)
			
			for slot in slots:
				if slot.data().icon == item.texture:
					slot.remove()
					
			print("Removed Successfully!")
			return
	
	print("Item Not Exist in the Inventory!")

#func invPath(path: String):
	##slots = get_tree().root.get_node(path).get_children()
	##print(get_tree().root.get_node("game/Inventory").get_child(0))
	#pass
	#
#func _on_visibility_changed():
	#if visible:
		##$BG.texture = InventoryBG if InventoryBG else preload("res://addons/inventory_system/inventory-slot.png")
		#for slot in slots:
			#slot.get_node("BG").texture = InventorySlotBG if InventorySlotBG else preload("res://addons/inventory_system/inventory-slot.png")

func getCount(itemName: String):
	for item in Inv:
		if item.name == itemName:
			return item.count
	print("Item Not exist!")
	
	return null
