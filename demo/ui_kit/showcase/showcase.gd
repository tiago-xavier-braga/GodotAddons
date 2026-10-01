extends Control

## Phase 5 demo: the three templates wired into one flow.
##
## This is the whole of what a consumer writes. Each template emits and the
## showcase decides where to go — no template knows about any other, and none
## of them contains navigation logic.

enum Screen {
	MAIN_MENU,
	GAMEPLAY,
	SETTINGS,
}

## Offered by the settings screen's palette picker.
@export var palettes: Array[UIPalette] = []

@onready var _main_menu: UIMainMenu = %MainMenu
@onready var _gameplay: Control = %Gameplay
@onready var _settings: UISettingsMenu = %SettingsMenu
@onready var _pause: UIPauseMenu = %PauseMenu
@onready var _status: Label = %Status
@onready var _last_change: Label = %LastChange

## Where Back on the settings screen returns to — it is reachable from both the
## main menu and the pause menu, and has to go back where it came from.
var _settings_came_from: Screen = Screen.MAIN_MENU


func _ready() -> void:
	_main_menu.play_pressed.connect(_show_screen.bind(Screen.GAMEPLAY))
	_main_menu.settings_pressed.connect(_open_settings.bind(Screen.MAIN_MENU))
	_main_menu.quit_pressed.connect(_on_quit_pressed)

	_pause.resume_pressed.connect(_on_resume_pressed)
	_pause.settings_pressed.connect(_open_settings.bind(Screen.GAMEPLAY))
	_pause.quit_pressed.connect(_on_quit_to_menu_pressed)

	_settings.back_pressed.connect(_on_settings_back_pressed)
	_settings.palette_changed.connect(_on_palette_changed)
	_settings.music_volume_changed.connect(_on_music_volume_changed)
	_settings.effects_volume_changed.connect(_on_effects_volume_changed)
	_settings.fullscreen_toggled.connect(_on_fullscreen_toggled)

	UIInput.device_changed.connect(_refresh_status.unbind(1))
	UIBreakpoints.breakpoint_changed.connect(_refresh_status.unbind(1))

	_show_screen(Screen.MAIN_MENU)
	_refresh_status()


func _unhandled_input(event: InputEvent) -> void:
	# The pause menu claims ui_cancel for itself while it is open, so reaching
	# here means it is not.
	if _gameplay.visible and event.is_action_pressed(&"ui_cancel"):
		_pause.open()
		get_viewport().set_input_as_handled()


func _show_screen(screen: Screen) -> void:
	_main_menu.visible = screen == Screen.MAIN_MENU
	_gameplay.visible = screen == Screen.GAMEPLAY
	_settings.visible = screen == Screen.SETTINGS


func _open_settings(from: Screen) -> void:
	_settings_came_from = from
	_show_screen(Screen.SETTINGS)


func _on_settings_back_pressed() -> void:
	if _settings_came_from == Screen.GAMEPLAY:
		# Still paused — the pause menu only hid itself — so going back means
		# putting it in front again rather than resuming.
		_show_screen(Screen.GAMEPLAY)
		_pause.open()
		return
	_show_screen(Screen.MAIN_MENU)


func _on_resume_pressed() -> void:
	_note("resumed")


func _on_quit_to_menu_pressed() -> void:
	_pause.close()
	_show_screen(Screen.MAIN_MENU)


func _on_quit_pressed() -> void:
	_note("quit pressed — a real game would call get_tree().quit()")


func _on_palette_changed(palette: UIPalette) -> void:
	_note("palette: %s" % palette.resource_name)


func _on_music_volume_changed(volume: float) -> void:
	_note("music volume: %d%%" % roundi(volume))


func _on_effects_volume_changed(volume: float) -> void:
	_note("effects volume: %d%%" % roundi(volume))


## The one setting the demo applies for real, to show where a game would.
func _on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	)
	_note("fullscreen: %s" % enabled)


func _refresh_status() -> void:
	_status.text = "%s   ·   %s" % [
		UIInput.get_active_device_name(),
		UIBreakpoints.get_active_breakpoint(),
	]


func _note(text: String) -> void:
	_last_change.text = text
