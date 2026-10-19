@tool
## Registers the [code]SaveKit[/code] autoload and its project settings when the plugin is
## enabled.
extends EditorPlugin

const AUTOLOAD_NAME: String = "SaveKit"
const AUTOLOAD_PATH: String = "res://addons/save_kit/save_kit.gd"
const SAVE_KIT := preload("res://addons/save_kit/save_kit.gd")
const PROJECT_NAME_SETTING: String = "application/config/name"


func _enter_tree() -> void:
	_add_setting(SAVE_KIT.SAVE_KEY_SETTING, _default_save_key(), PROPERTY_HINT_NONE, "")
	_add_setting(SAVE_KIT.DEFAULTS_FILE_SETTING, "", PROPERTY_HINT_FILE, "*.json")
	_add_setting(SAVE_KIT.CUSTOM_STORAGE_SETTING, "", PROPERTY_HINT_FILE, "*.gd")


func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)


# The settings stay, so turning the plugin off and on again never changes the save key.
func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)


func _add_setting(setting: String, value: String, hint: PropertyHint, hint_string: String) -> void:
	if not ProjectSettings.has_setting(setting):
		ProjectSettings.set_setting(setting, value)
		ProjectSettings.save()
	ProjectSettings.set_as_basic(setting, true)
	ProjectSettings.add_property_info({
		"name": setting,
		"type": TYPE_STRING,
		"hint": hint,
		"hint_string": hint_string,
	})


func _default_save_key() -> String:
	return (ProjectSettings.get_setting(PROJECT_NAME_SETTING) as String).to_snake_case()
