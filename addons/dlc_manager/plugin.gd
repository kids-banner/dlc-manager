@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("DlcManager", "res://addons/dlc_manager/DlcManager.gd")
	pass


func _exit_tree() -> void:
	remove_autoload_singleton("DlcManager")
	pass
