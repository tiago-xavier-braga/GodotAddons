@tool
extends EditorPlugin

## Installs UI Kit into the consumer's project.
##
## The autoloads and project settings are registered from
## [method _enable_plugin] and removed from [method _disable_plugin] — the
## hooks that run once, when the checkbox in
## [code]Project Settings > Plugins[/code] is ticked and unticked. Doing it in
## [method _enter_tree]/[method _exit_tree] instead would re-register on every
## editor start and, worse, strip the autoload back out of the consumer's
## [code]project.godot[/code] every time they close the editor.

const AUTOLOADS: Dictionary[StringName, String] = {
	&"UIInput": "res://addons/ui_kit/input/ui_input.gd",
	&"UIBreakpoints": "res://addons/ui_kit/responsive/ui_breakpoints.gd",
}

## Settings the addon exposes under [code]Project Settings[/code], as
## setting path -> default value.
const SETTINGS: Dictionary[String, Variant] = {
	"ui_kit/breakpoints/desktop_min_short_side": 600,
}


func _enable_plugin() -> void:
	for singleton_name: StringName in AUTOLOADS:
		# A project that already declares the autoload by hand keeps its own
		# entry instead of getting a duplicate.
		if not ProjectSettings.has_setting("autoload/" + singleton_name):
			add_autoload_singleton(singleton_name, AUTOLOADS[singleton_name])

	for path: String in SETTINGS:
		if not ProjectSettings.has_setting(path):
			ProjectSettings.set_setting(path, SETTINGS[path])
		ProjectSettings.set_initial_value(path, SETTINGS[path])
		ProjectSettings.set_as_basic(path, true)
	ProjectSettings.save()


func _disable_plugin() -> void:
	for singleton_name: StringName in AUTOLOADS:
		if ProjectSettings.has_setting("autoload/" + singleton_name):
			remove_autoload_singleton(singleton_name)

	for path: String in SETTINGS:
		# A value the project retuned is theirs to keep — disabling the plugin
		# to reorganise something should not quietly discard it. Only the
		# untouched default is cleaned up.
		if ProjectSettings.get_setting(path, SETTINGS[path]) == SETTINGS[path]:
			ProjectSettings.set_setting(path, null)
	ProjectSettings.save()
