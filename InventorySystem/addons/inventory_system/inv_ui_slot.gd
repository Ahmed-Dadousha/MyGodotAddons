extends Panel


@onready var item_visual: TextureRect = $Item

func update(count: int):
	$Count.text = str(count)
	
func remove():
	$Item.texture = null
	$Count.text = ""
	
func insert(item: InvItem):
	item_visual.texture = item.texture
	$Count.text = str(item.count)
	
func data():
	return Dictionary({"count": str($Count.text) , "icon": $Item.texture})
