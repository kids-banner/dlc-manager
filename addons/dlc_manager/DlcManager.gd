extends Node

# Lists all dlcs
# Download all dlcs, or each one by name
# Check for updates

signal dlc_config_updated
signal dlc_config_update_failed(code: int, message: String)

signal dlc_downloaded(id: String)
signal dlc_download_failed(code: int, message: String)

signal dlc_installed(id: String)
signal dlc_install_failed(code: int, message: String)

var dlc_config: DlcConfiguration = preload("res://config/_default_dlc_config.tres") as DlcConfiguration

var pck_downloader: HTTPRequest
var config_downloader: HTTPRequest
var loaded_dlc_config: Dictionary


func _ready() -> void:
	var app_version = ProjectSettings.get_setting("application/config/version", "0.0")
	pck_downloader = _create_http_node("pck_downloader")
	config_downloader = _create_http_node("config_downloader")
	loaded_dlc_config = dlc_config.load_dlc_config()


func _create_http_node(name: String) -> HTTPRequest:
	var http: HTTPRequest = HTTPRequest.new()
	http.set_name(name)
	http.set_accept_gzip(true)
	http.set_download_file("")
	add_child(http)
	return http


### Remote DLC management
func fetch_dlc_config() -> void:
	config_downloader.request(loaded_dlc_config["configUrl"])
	var completion := await config_downloader.request_completed
	if completion.result != OK:
		dlc_config_update_failed.emit(completion.response_code, completion.body.get_string_from_utf8())
		return

	var json_string: String = completion.body.get_string_from_utf8()
	var json: Dictionary = JSON.parse_string(json_string)
	if json:
		loaded_dlc_config = json
		_store_dlc_config(json_string)
		dlc_config_updated.emit()
	else:
		dlc_config_update_failed.emit(ERR_FILE_CORRUPT, "Failed to parse DLC config")


func is_downloaded(id: String) -> bool:
	var dlc: Dictionary = _get_dlc(id)
	if !dlc:
		return false

	var path: String = dlc_config.dlc_path(dlc["filename"])

	if !FileAccess.file_exists(path):
		return false

	if FileAccess.get_md5(path) == dlc["checksum"]:
		return true

	return false

func download_dlc(id: String) -> void:
	var dlc: Dictionary = _get_dlc(id)
	if !dlc:
		dlc_download_failed.emit(ERR_INVALID_PARAMETER, "DLC not found: " + id)
		return

	var dlc = loaded_dlc_config["dlc"][id]
	pck_downloader.request(dlc["url"])
	var completion := await pck_downloader.request_completed

	if completion.result != OK:
		dlc_download_failed.emit(completion.response_code, completion.body.get_string_from_utf8())
		return

	var file: FileAccess = FileAccess.open(dlc_config.dlc_path(dlc["filename"]), FileAccess.WRITE)
	file.store_buffer(completion.body)


func _store_dlc_config(json_string: String) -> void:
	var file: FileAccess = FileAccess.open(dlc_config.dlc_path("dlc_config.json"), FileAccess.WRITE)
	file.store_string(json_string)


### Local DLC management
func load_all_dlcs() -> void:
	for id in get_available_dlc_ids():
		load_dlc(id)


func load_dlc(id: String) -> bool:
	var dlc: Dictionary = _get_dlc(id)
	if !dlc:
		return false

	var path: String = dlc_config.dlc_path(dlc["filename"])
	if !FileAccess.file_exists(path):
		return false

	return ProjectSettings.load_resource_pack(path, true)


func installed_dlcs() -> Array[String]:
	var dlcs: Array[String] = []
	var packs: Array = ProjectSettings.get_setting("application/config/resource_packs", [])
	for pack in packs:
		if pack["enabled"]:
			dlcs.append(pack["path"])
	return dlcs


func get_available_dlc_ids() -> Array[String]:
	var dlcs: Array[String] = []
	if loaded_dlc_config && loaded_dlc_config["dlc"]:
		dlcs = loaded_dlc_config["dlc"].keys()
	return dlcs


func _get_dlc(id: String) -> Dictionary:
	if !loaded_dlc_config || !loaded_dlc_config["dlc"]:
		return null

	return loaded_dlc_config["dlc"][id]

