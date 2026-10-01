class_name UIMainMenu
extends Control

## A ready-made main menu. Instance it, connect its three signals, done.
##
## It has no theme of its own on purpose: [Control] theme lookup walks up the
## tree, so the template picks up whatever [UITheme] the game's root sets. That
## also means it looks unstyled when you open this scene on its own in the
## editor, which is correct rather than broken.
##
## Focus order is Godot's: every button sits in a [Container], so
## [member Control.focus_neighbor_top] and friends are computed from node
## positions and there is nothing to wire.

signal play_pressed
signal settings_pressed
signal quit_pressed

@export var title: String = "Game Title":
	set(value):
		title = value
		if is_node_ready():
			_title.text = value

## Hides Quit on the web, where quitting a tab-hosted game does nothing useful.
@export var hide_quit_on_web: bool = true

@onready var _title: Label = %Title
@onready var _play_button: Button = %PlayButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	_title.text = title
	_play_button.pressed.connect(play_pressed.emit)
	%SettingsButton.pressed.connect(settings_pressed.emit)
	_quit_button.pressed.connect(quit_pressed.emit)

	if hide_quit_on_web and OS.has_feature("web"):
		_quit_button.hide()

	if visible:
		focus_first()


func _notification(what: int) -> void:
	# Re-entering from the settings screen has to hand focus back, or a pad
	# player is left with nothing selected.
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_node_ready() and visible:
		focus_first()


## Puts focus on the first button, so keyboard and pad navigation has a start.
func focus_first() -> void:
	_play_button.grab_focus()
