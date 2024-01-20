extends HBoxContainer

signal Join(ip: String)


func _on_join_pressed():
	Join.emit($IP.text)
