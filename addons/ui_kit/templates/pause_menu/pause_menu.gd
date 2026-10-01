class_name UIPauseMenu
extends Control

## A ready-made pause screen, using Godot's own pause system and nothing else.
##
## [method open] sets [member SceneTree.paused]; the root node's
## [constant Node.PROCESS_MODE_ALWAYS] is what keeps this menu — and only this
## menu — running while everything else is stopped. There is no custom pause
## state anywhere in the kit.
##
## The scrim behind the buttons is a [ColorRect] tinted from the palette, so it
## re-skins with everything else.

signal resume_pressed
signal settings_pressed
signal quit_pressed

@onready var _scrim: ColorRect = %Scrim
@onready var _resume_button: Button = %ResumeButton


func _ready() -> void:
	_resume_button.pressed.connect(resume)
	%SettingsButton.pressed.connect(_on_settings_pressed)
	%QuitButton.pressed.connect(quit_pressed.emit)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel"):
		resume()
		get_viewport().set_input_as_handled()


## Shows the menu and pauses the tree.
func open() -> void:
	_tint_scrim()
	show()
	get_tree().paused = true
	_resume_button.grab_focus()


## Hides the menu and unpauses the tree, without emitting anything. For the
## game to call — a cutscene ending, a level reload.
func close() -> void:
	hide()
	get_tree().paused = false


## What the Resume button and `ui_cancel` both do: close, then say so.
func resume() -> void:
	close()
	resume_pressed.emit()


## Hides the menu but stays paused, so the settings screen shown in its place
## is paused too. The game decides what to show; call [method open] again to
## come back.
func _on_settings_pressed() -> void:
	hide()
	settings_pressed.emit()


## The scrim colour is a token, not a constant, so it follows the palette. It
## is read on open rather than in _ready because the theme may have been
## re-skinned in between — by this kit's own settings screen, most likely.
func _tint_scrim() -> void:
	var inherited := UITheme.find_in_ancestors(self)
	var background := Color.BLACK
	if inherited != null and inherited.palette != null:
		background = inherited.palette.background
	_scrim.color = Color(background, UIMetrics.SCRIM_ALPHA)
