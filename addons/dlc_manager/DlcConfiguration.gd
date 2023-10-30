extends Resource
class_name DlcConfiguration

# The config file url & location.
# An example of the config file:
# {
#   "config_url": "https://mygame.com/dlc_config.json",
#   "dlc": [
#     {
#       "name": "DLC1",
#       "url": "https://mygame.com/dlc1.pck",
#		"checksum": "1234567890abcdef1234567890abcdef12345678",
#       "compat_versions": ["1.0", "2.0"] // DLC1 works for both 1.0 and 2.0
#     },
#     {
#       "name": "DLC2",
#       "url": "https://mygame.com/dlc2.zip",
#		"checksum": "1234567890abcdef1234567890abcdef12345678",
#       "compat_versions": ["1.0"]
#     },
#     {
#       "name": "DLC3",
#       "url": "https://mygame.com/dlc3.pck",
#		"checksum": "1234567890abcdef1234567890abcdef12345678",
#       "compat_versions": ["2.0"]
#     }
#   ]
# }

@export var config_location: String = "res://dlc_config.json"
@export var config_url: String = "https://mygame.com/dlc_config.json"
