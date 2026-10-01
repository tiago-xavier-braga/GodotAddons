extends UIKitTestCase

## Tests for the three menu templates.

const THEME := "res://addons/ui_kit/theme/default_theme.tres"
const MAIN_MENU := "res://addons/ui_kit/templates/main_menu/main_menu.tscn"
const PAUSE_MENU := "res://addons/ui_kit/templates/pause_menu/pause_menu.tscn"
const SETTINGS_MENU := "res://addons/ui_kit/templates/settings_menu/settings_menu.tscn"

var _stage: Control
var _emitted: PackedStringArray = []


func run() -> void:
	await _test_main_menu_signals()
	await _test_focus_order_is_godots()
	await _test_pause_menu_uses_the_engine_pause()
	await _test_pause_menu_resumes_on_cancel()
	await _test_pause_menu_keeps_the_tree_paused_for_settings()
	await _test_settings_palette_picker_reskins()
	await _test_settings_reports_without_applying()
	await _test_every_focusable_control_is_touch_sized()
	_teardown()
	get_tree().paused = false


func _test_main_menu_signals() -> void:
	var menu := await _mount(MAIN_MENU) as UIMainMenu
	_emitted.clear()
	menu.play_pressed.connect(_note.bind("play"))
	menu.settings_pressed.connect(_note.bind("settings"))
	menu.quit_pressed.connect(_note.bind("quit"))

	menu.get_node("%PlayButton").pressed.emit()
	menu.get_node("%SettingsButton").pressed.emit()
	menu.get_node("%QuitButton").pressed.emit()

	check_equal(_emitted, PackedStringArray(["play", "settings", "quit"]), "the three buttons emit")

	menu.title = "Renamed"
	check_equal((menu.get_node("%Title") as Label).text, "Renamed", "the title export is live")


## The roadmap's bet is that sitting inside a [Container] is enough and no
## focus_neighbor_* has to be written by hand. This is that bet, checked.
func _test_focus_order_is_godots() -> void:
	var menu := await _mount(MAIN_MENU) as UIMainMenu
	var play: Button = menu.get_node("%PlayButton")
	var settings: Button = menu.get_node("%SettingsButton")
	var quit: Button = menu.get_node("%QuitButton")

	check_equal(play.focus_neighbor_bottom, NodePath(), "no neighbour is wired by hand")
	check_equal(
		play.find_valid_focus_neighbor(SIDE_BOTTOM), settings, "down from Play reaches Settings"
	)
	check_equal(
		settings.find_valid_focus_neighbor(SIDE_BOTTOM), quit, "down from Settings reaches Quit"
	)
	check_equal(quit.find_valid_focus_neighbor(SIDE_TOP), settings, "up from Quit reaches Settings")

	check_equal(menu.get_viewport().gui_get_focus_owner(), play, "the menu grabs focus on show")


func _test_pause_menu_uses_the_engine_pause() -> void:
	var menu := await _mount(PAUSE_MENU) as UIPauseMenu
	check(not menu.visible, "the pause menu starts hidden")
	check(not get_tree().paused, "and does not pause anything until opened")
	check_equal(
		menu.process_mode,
		Node.PROCESS_MODE_ALWAYS,
		"the root runs while paused, which is the only reason the menu works"
	)

	menu.open()
	await next_frame()
	check(menu.visible, "open() shows the menu")
	check(get_tree().paused, "open() pauses the tree — Godot's pause, not ours")
	check_equal(
		menu.get_viewport().gui_get_focus_owner(),
		menu.get_node("%ResumeButton"),
		"open() puts focus on Resume"
	)

	menu.close()
	await next_frame()
	check(not menu.visible, "close() hides the menu")
	check(not get_tree().paused, "close() unpauses the tree")


func _test_pause_menu_resumes_on_cancel() -> void:
	var menu := await _mount(PAUSE_MENU) as UIPauseMenu
	_emitted.clear()
	menu.resume_pressed.connect(_note.bind("resume"))

	menu.open()
	await next_frame()

	var cancel := InputEventAction.new()
	cancel.action = &"ui_cancel"
	cancel.pressed = true
	Input.parse_input_event(cancel)
	await next_frame()

	check(not get_tree().paused, "ui_cancel unpauses")
	check(not menu.visible, "ui_cancel hides the menu")
	check_equal(_emitted, PackedStringArray(["resume"]), "ui_cancel emits resume_pressed once")


## Settings is reachable from the pause menu, and the game behind it has to
## stay stopped while you are in there.
func _test_pause_menu_keeps_the_tree_paused_for_settings() -> void:
	var menu := await _mount(PAUSE_MENU) as UIPauseMenu
	menu.open()
	await next_frame()

	menu.get_node("%SettingsButton").pressed.emit()
	await next_frame()

	check(not menu.visible, "the pause menu steps aside for the settings screen")
	check(get_tree().paused, "but the tree stays paused behind it")

	menu.close()
	await next_frame()


func _test_settings_palette_picker_reskins() -> void:
	var first := UIPalette.new()
	first.resource_name = "First"
	var second := UIPalette.new()
	second.resource_name = "Second"
	second.accent = Color.MAGENTA

	var menu := await _mount(SETTINGS_MENU, func(node: Node) -> void:
		(node as UISettingsMenu).palettes = [first, second]
	) as UISettingsMenu
	_emitted.clear()
	menu.palette_changed.connect(func(palette: UIPalette) -> void: _note(palette.resource_name))

	var row: HFlowContainer = menu.get_node("%PaletteRow")
	check_equal(row.get_child_count(), 2, "one button per palette")
	check_equal((row.get_child(0) as Button).text, "First", "buttons are named after the palettes")

	var second_button := row.get_child(1) as UIButton
	second_button.pressed.emit()
	await next_frame()

	var inherited := _stage.theme as UITheme
	check_equal(inherited.palette, second, "pressing a palette applies it to the inherited theme")
	check_equal(
		(inherited.get_stylebox(&"normal", UIVariants.PRIMARY_BUTTON) as StyleBoxFlat).bg_color,
		Color.MAGENTA,
		"and the theme is rebuilt from it"
	)
	check_equal(_emitted, PackedStringArray(["Second"]), "palette_changed carries the palette")
	check_equal(
		second_button.variation, UIButton.Variation.PRIMARY, "the chosen palette reads as primary"
	)
	check_equal(
		(row.get_child(0) as UIButton).variation,
		UIButton.Variation.SECONDARY,
		"and the others fall back to secondary"
	)


## Everything except the palette is reported, not applied — the game owns its
## audio buses and its window mode.
func _test_settings_reports_without_applying() -> void:
	var menu := await _mount(SETTINGS_MENU) as UISettingsMenu
	_emitted.clear()
	menu.music_volume_changed.connect(func(v: float) -> void: _note("music %d" % roundi(v)))
	menu.fullscreen_toggled.connect(func(on: bool) -> void: _note("fullscreen %s" % on))

	(menu.get_node("%MusicSlider") as HSlider).value = 30.0
	(menu.get_node("%FullscreenCheck") as CheckBox).button_pressed = true
	await next_frame()
	check_equal(
		_emitted, PackedStringArray(["music 30", "fullscreen true"]), "changes are reported"
	)

	# Loading saved settings back in must not echo them straight out again.
	_emitted.clear()
	menu.set_music_volume(75.0)
	menu.set_fullscreen(false)
	await next_frame()
	check_equal(_emitted, PackedStringArray([]), "setting values back in emits nothing")
	check_equal((menu.get_node("%MusicSlider") as HSlider).value, 75.0, "but the slider moved")

	check(
		menu.get_node("%PaletteSection").visible == false,
		"the palette row hides itself when no palettes are offered"
	)


## Touch-friendly hit areas, checked rather than assumed — across all three
## templates, after real layout.
func _test_every_focusable_control_is_touch_sized() -> void:
	for scene_path: String in [MAIN_MENU, PAUSE_MENU, SETTINGS_MENU]:
		var menu := await _mount(scene_path, func(node: Node) -> void:
			if node is UISettingsMenu:
				(node as UISettingsMenu).palettes = [UIPalette.new()]
		)
		menu.visible = true
		await next_frame()
		await next_frame()

		var small: PackedStringArray = []
		for control: Control in _focusable_controls(menu):
			if control.size.y + 0.01 < UIMetrics.MIN_TOUCH_TARGET:
				small.append("%s (%d px tall)" % [control.name, roundi(control.size.y)])

		check_equal(
			small,
			PackedStringArray([]),
			"%s: every focusable control clears the touch target" % scene_path.get_file()
		)


# --- fixture ---


func _mount(scene_path: String, configure: Callable = Callable()) -> Control:
	_teardown()

	_stage = Control.new()
	# A private copy, so a test that re-skins does not scribble on the shipped
	# theme resource.
	var shipped := load(THEME) as UITheme
	var theme := UITheme.new()
	theme.palette = shipped.palette.duplicate() as UIPalette
	theme.typography = shipped.typography.duplicate() as UITypography
	_stage.theme = theme
	_stage.size = Vector2(1000, 700)
	add_child(_stage)

	var menu := (load(scene_path) as PackedScene).instantiate() as Control
	# No explicit size: the templates anchor to all four sides, so they take the
	# stage's size on their own. Assigning it would be overridden anyway, and
	# Godot warns about exactly that.
	if configure.is_valid():
		configure.call(menu)
	_stage.add_child(menu)
	await next_frame()
	return menu


func _teardown() -> void:
	if _stage != null and _stage.is_inside_tree():
		remove_child(_stage)
		_stage.free()
	_stage = null


func _focusable_controls(root: Node) -> Array[Control]:
	var found: Array[Control] = []
	for child: Node in root.get_children():
		if child is Control:
			var control := child as Control
			if control.focus_mode != Control.FOCUS_NONE and control.is_visible_in_tree():
				found.append(control)
		found.append_array(_focusable_controls(child))
	return found


func _note(text: String) -> void:
	_emitted.append(text)
