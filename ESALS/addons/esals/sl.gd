extends Node

var SAVE_DIR: String = ""
var SAVE_FILE_NAME: String = ""
var SECURITY_KEY: String = ""
var FULL_PATH: String = ""
func Set(save_dir: String = "user://saves/", save_file_name: String = "save.json", security_key: String = "1DF7S7H"):
	SAVE_DIR = save_dir
	SAVE_FILE_NAME = save_file_name
	SECURITY_KEY = security_key
	FULL_PATH = SAVE_DIR + SAVE_FILE_NAME
	
	# Create Save folder if not exists
	verify_player_data(SAVE_DIR)
	
func verify_player_data(path: String):
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)
	
func save_data(data: Dictionary):
	# Open the file with write access
	var file = FileAccess.open_encrypted_with_pass(FULL_PATH, FileAccess.WRITE, SECURITY_KEY)
	
	# Open Error
	if file == null:
		print(FileAccess.get_open_error())
		return
		
	# Convert data into JSON 
	var json_string = JSON.stringify(data, "\t")
	
	# Save the data 
	file.store_string(json_string)
	
	# Close the file
	file.close()
	print("Save Done!")
	
func load_data():
	# Check if file is not exists 
	if !FileAccess.file_exists(FULL_PATH):
		printerr("Cannot open non-existent file at %s!" % [FULL_PATH])
		return
	
	# Open the file with read access
	var file = FileAccess.open_encrypted_with_pass(FULL_PATH, FileAccess.READ, SECURITY_KEY)
	if file == null:
		print(FileAccess.get_open_error())
		return

	var content = file.get_as_text()
	# Close the file
	file.close()

	# Convert data into string
	var data = JSON.parse_string(content)
	if data == null:
		printerr("Cannot parse %s as a json_string: (%s)" % [FULL_PATH, content])
		return
	
	print("Load Done!")
	return data

