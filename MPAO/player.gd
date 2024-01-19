extends CharacterBody2D

const SPEED: int = 300

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _process(_delta):
	if not is_multiplayer_authority(): return
	velocity = Input.get_vector("left", "right", "up", "down") * SPEED
	move_and_slide()
