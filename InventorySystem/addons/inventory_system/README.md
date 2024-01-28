# Inventory System

# Technologies
Godot 4.2.

# Setup
Put the addon in addons folder.

# Usage
- Enable the plugin.
- By default it will be hidden.
- Set Inventory and slot background.
- Call `addItem({"name": "name", "icon":"your icon path"})` to add a new item or update an item count.
- Call `removeItem("Name of the Item to delete")` to remove an item.
- Call `getCount(itemName)` to get count of an item; if item not exist it will return `null`.
