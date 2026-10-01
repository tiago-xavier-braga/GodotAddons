extends UIKitTestCase

## Checks the monorepo's central promise about an addon: that
## [code]addons/ui_kit/[/code] is exactly what a consumer copies, and that
## copying it is enough.
##
## This is the test that would have caught the addon's own README linking to
## `../../docs/`, and that will catch the first time a template reaches into
## `demo/` or `assets/` for a placeholder.

const ADDON_ROOT := "res://addons/ui_kit"

## Files whose contents can name a dependency. `.import` and `.uid` are
## generated and legitimately point into `res://.godot/`.
const SCANNED_EXTENSIONS: PackedStringArray = ["gd", "tscn", "tres", "cfg", "md"]

## Anything the addon is allowed to reference outside its own folder. Empty on
## purpose: there is nothing, and adding an entry here should take an argument.
const ALLOWED_OUTSIDE: PackedStringArray = []


func run() -> void:
	_test_no_runtime_path_leaves_the_addon()
	_test_the_autoload_paths_exist()
	_test_the_addon_carries_its_own_licenses()
	_test_nothing_outside_the_addon_is_an_autoload()


func _test_no_runtime_path_leaves_the_addon() -> void:
	var files := _files_under(ADDON_ROOT)
	check(files.size() > 10, "the scan found the addon's files at all (%d)" % files.size())

	var leaks: PackedStringArray = []
	for file_path: String in files:
		if not SCANNED_EXTENSIONS.has(file_path.get_extension()):
			continue
		var text := FileAccess.get_file_as_string(file_path)
		for reference: String in _res_references(text):
			if reference.begins_with(ADDON_ROOT + "/") or ALLOWED_OUTSIDE.has(reference):
				continue
			leaks.append("%s -> %s" % [file_path.trim_prefix(ADDON_ROOT + "/"), reference])

	check_equal(leaks, PackedStringArray([]), "no file in the addon references a path outside it")

	# Markdown links are not res:// paths, so they need their own look: a
	# relative link out of the folder is a dead link once the folder is copied.
	var dead_links: PackedStringArray = []
	for file_path: String in files:
		if file_path.get_extension() != "md":
			continue
		if FileAccess.get_file_as_string(file_path).contains("](../"):
			dead_links.append(file_path.get_file())
	check_equal(
		dead_links, PackedStringArray([]), "no document in the addon links above the addon folder"
	)


func _test_the_autoload_paths_exist() -> void:
	var plugin: GDScript = load(ADDON_ROOT + "/ui_kit.gd")
	var autoloads: Dictionary = plugin.get("AUTOLOADS")
	check(autoloads.size() > 0, "the plugin declares autoloads")

	for singleton_name: StringName in autoloads:
		var path: String = autoloads[singleton_name]
		check(
			ResourceLoader.exists(path),
			"the autoload %s points at a script that exists (%s)" % [singleton_name, path]
		)
		check(
			path.begins_with(ADDON_ROOT + "/"),
			"the autoload %s lives inside the addon" % singleton_name
		)


func _test_the_addon_carries_its_own_licenses() -> void:
	for required: String in [
		"/LICENSE",
		"/THIRDPARTY.md",
		"/fonts/noto_sans_license.txt",
		"/components/focus_prompt/glyphs/kenney_license.txt",
	]:
		check(
			FileAccess.file_exists(ADDON_ROOT + required),
			"the copied folder includes %s" % required.trim_prefix("/")
		)


## The reverse direction: a consumer enabling the plugin must not end up with
## an autoload pointing at this repo's development files.
func _test_nothing_outside_the_addon_is_an_autoload() -> void:
	var offenders: PackedStringArray = []
	for property: Dictionary in ProjectSettings.get_property_list():
		var setting: String = property.get("name", "")
		if not setting.begins_with("autoload/"):
			continue
		var target := _resolve(str(ProjectSettings.get_setting(setting)).trim_prefix("*"))
		if not target.begins_with(ADDON_ROOT + "/"):
			offenders.append("%s -> %s" % [setting, target])
	check_equal(
		offenders,
		PackedStringArray([]),
		"every autoload in this project comes from inside the addon"
	)


## Autoloads may be stored either way: Godot 4.7's
## [method EditorPlugin.add_autoload_singleton] writes a [code]uid://[/code]
## reference, which survives the folder being moved, while a hand-written
## [code]project.godot[/code] usually has a [code]res://[/code] path.
func _resolve(reference: String) -> String:
	if not reference.begins_with("uid://"):
		return reference
	var id := ResourceUID.text_to_id(reference)
	return ResourceUID.get_id_path(id) if ResourceUID.has_id(id) else reference


func _files_under(directory: String) -> PackedStringArray:
	var found: PackedStringArray = []
	var dir := DirAccess.open(directory)
	if dir == null:
		return found

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var path := directory.path_join(entry)
		if dir.current_is_dir():
			found.append_array(_files_under(path))
		else:
			found.append(path)
		entry = dir.get_next()
	dir.list_dir_end()
	return found


## Every `res://...` path mentioned in [param text], however it is quoted.
func _res_references(text: String) -> PackedStringArray:
	var found: PackedStringArray = []
	var regex := RegEx.create_from_string('res://[^"\'\\s\\)\\]]+')
	for result: RegExMatch in regex.search_all(text):
		var reference := result.get_string().trim_suffix(".")
		if not found.has(reference):
			found.append(reference)
	return found
