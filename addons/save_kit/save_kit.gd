extends Node

## Loads the game's save at startup and writes it back on [method save]. The game declares every
## key and its default value in the JSON file set in [code]save_kit/defaults_file[/code].

const SAVE_KEY_SETTING: String = "save_kit/save_key"
const DEFAULTS_FILE_SETTING: String = "save_kit/defaults_file"
const CUSTOM_STORAGE_SETTING: String = "save_kit/custom_storage"
const FORMAT_VERSION: int = 1
const VERSION_FIELD: String = "version"
const DATA_FIELD: String = "data"
const UNKNOWN_KEY_ERROR: String = "SaveKit: \"%s\" is not in the defaults file."

var _storage: SaveStorage = null
var _save_key: String = ""
var _defaults: Dictionary = {}
var _data: Dictionary = {}


# In _init, so other autoloads can read values in their _ready whatever their order.
func _init() -> void:
	_storage = _create_storage()
	_save_key = ProjectSettings.get_setting(SAVE_KEY_SETTING, "")
	_defaults = _load_defaults()
	_data = _defaults.duplicate(true)
	var text: String = _storage.read(_save_key)
	if not text.is_empty():
		_data.merge(_parse(text), true)


## Returns the value typed like its default, since JSON reads every saved number back as a float.
func get_value(key: String) -> Variant:
	if not _defaults.has(key):
		push_error(UNKNOWN_KEY_ERROR % key)
		return null
	return type_convert(_data[key], typeof(_defaults[key]))


## Changes the value in memory only; call [method save] to keep it.
func set_value(key: String, value: Variant) -> void:
	if not _defaults.has(key):
		push_error(UNKNOWN_KEY_ERROR % key)
		return
	_data[key] = value


func save() -> void:
	var text: String = JSON.stringify({VERSION_FIELD: FORMAT_VERSION, DATA_FIELD: _data}, "\t")
	if not _storage.write(_save_key, text):
		push_warning("SaveKit: the save couldn't be written, so progress lasts this session only.")


func _create_storage() -> SaveStorage:
	var custom_path: String = ProjectSettings.get_setting(CUSTOM_STORAGE_SETTING, "")
	if not custom_path.is_empty():
		return (load(custom_path) as GDScript).new()
	if OS.has_feature("web"):
		return SaveWebStorage.new()
	return SaveFileStorage.new()


# str_to_var keeps 1 an int and 1.0 a float, which JSON can't. It's safe here, unlike on the save,
# because the defaults file ships with the game.
func _load_defaults() -> Dictionary:
	var path: String = ProjectSettings.get_setting(DEFAULTS_FILE_SETTING, "")
	assert(not path.is_empty(), "SaveKit: set the save_kit/defaults_file project setting.")
	return str_to_var(FileAccess.get_file_as_string(path))


# A broken save gives no values, so the game starts from the defaults instead of crashing.
func _parse(text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary and (parsed as Dictionary).get(DATA_FIELD) is Dictionary:
		return parsed[DATA_FIELD]
	push_error("SaveKit: the save is broken, so the game starts from the defaults.")
	return {}
