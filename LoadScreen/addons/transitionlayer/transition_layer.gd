extends CanvasLayer

func animate():
	show()
	$AnimationPlayer.play("fade")
	await $AnimationPlayer.animation_finished
	hide()
	
func animate_reverse():
	show()
	$AnimationPlayer.play_backwards("fade")
	await $AnimationPlayer.animation_finished
	hide()
