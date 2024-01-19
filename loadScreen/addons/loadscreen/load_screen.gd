extends Control



var nextScene: String = ""

var progress = []
var current_progress
var scene_load_status = 0
# Called when the node enters the scene tree for the first time.
func _load():
	ResourceLoader.load_threaded_request(nextScene)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $ProgressBar.value == 100:
		fade()

func _on_timer_timeout():
	$ProgressBar.value += 10

func set_next_scene(scene):
	nextScene = scene
	$Timer.start()
	_load()
	show()

func change():
	scene_load_status = ResourceLoader.load_threaded_get_status(nextScene, progress)
	current_progress = floor(progress[0]*100)

	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var newScene = ResourceLoader.load_threaded_get(nextScene)
		get_tree().change_scene_to_packed(newScene)

func reset():
	$Timer.stop()
	$ProgressBar.value = 0
	hide()

func fade():
	await TransitionLayer.animate()
	
	change()
	reset()	
	
	await TransitionLayer.animate_reverse()

	
	
