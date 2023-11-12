@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("DlcManager", "res://addons/dlc_manager/DlcManager.gd")
	_create_dlc_config()
	pass


func _exit_tree() -> void:
	remove_autoload_singleton("DlcManager")
	pass


func _create_dlc_config() -> void:
	var path: String = "res://config/_default_dlc_config.tres"
	if !FileAccess.file_exists(path):
		DirAccess.make_dir_absolute("res://config")
		ResourceSaver.save( DlcConfiguration.new(), path)
