extends Resource
class_name DlcConfiguration

# The location of the configuration file
@export var config_location: String = "res://dlc/dlc_config.json"

# The location of the dlc download files
@export var dlc_download_location: String = "user://dlc/"


func load_dlc_config() -> Dictionary:
	# todo check if there's a config file in user://dlc/ and use that instead, but also check if it's still valid after the user updated the app.
	var config_file: FileAccess = FileAccess.open(config_location, FileAccess.READ)
	return JSON.parse_string(config_file.get_as_text())


func dlc_path(filename: String) -> String:
	var path: String = dlc_download_location
	if !path.ends_with("/"):
		path += "/"

	DirAccess.make_dir_absolute(path)
	return path + filename
