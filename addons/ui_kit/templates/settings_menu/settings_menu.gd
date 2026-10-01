class_name UISettingsMenu
extends Control

## A ready-made settings screen: a live palette picker, two volume sliders and
## a fullscreen toggle.
##
## It reports choices and applies none of them, except the palette. A settings
## screen that reached into the audio buses or the window mode would be
## guessing at decisions that belong to the game — how many buses there are,
## exclusive fullscreen or borderless — so the rows emit signals and the game
## acts on them. The palette is the exception because re-skinning is this
## kit's own job, and doing it here is the clearest possible demonstration of
## it: press a name, and every screen behind this one changes colour.

signal back_pressed
signal palette_changed(palette: UIPalette)
signal music_volume_changed(volume: float)
signal effects_volume_changed(volume: float)
signal fullscreen_toggled(enabled: bool)

## Palettes offered by the picker. Leave empty to hide the whole row.
@export var palettes: Array[UIPalette] = []

## The theme the picker re-skins. Left empty, it uses the nearest [UITheme]
## above this node — which is the game's, since the templates set none.
@export var target_theme: UITheme

@onready var _palette_section: Control = %PaletteSection
@onready var _palette_row: HFlowContainer = %PaletteRow
@onready var _music: HSlider = %MusicSlider
@onready var _effects: HSlider = %EffectsSlider
@onready var _fullscreen: CheckBox = %FullscreenCheck
@onready var _back_button: Button = %BackButton

var _palette_buttons: Array[UIButton] = []


func _ready() -> void:
	_back_button.pressed.connect(back_pressed.emit)
	_music.value_changed.connect(music_volume_changed.emit)
	_effects.value_changed.connect(effects_volume_changed.emit)
	_fullscreen.toggled.connect(fullscreen_toggled.emit)

	_build_palette_picker()

	if visible:
		focus_first()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_node_ready() and visible:
		focus_first()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel"):
		back_pressed.emit()
		get_viewport().set_input_as_handled()


## Puts focus on the first control a player would reach.
func focus_first() -> void:
	if not _palette_buttons.is_empty():
		_palette_buttons[0].grab_focus()
	else:
		_music.grab_focus()


## Shows [param volume] on the music slider without emitting — for loading
## saved settings back in.
func set_music_volume(volume: float) -> void:
	_music.set_value_no_signal(volume)


func set_effects_volume(volume: float) -> void:
	_effects.set_value_no_signal(volume)


func set_fullscreen(enabled: bool) -> void:
	_fullscreen.set_pressed_no_signal(enabled)


## One button per palette, rather than an [OptionButton].
##
## A popup menu is a second surface to theme, costs an extra press on a pad,
## and hides the options until you open it — for three or four palettes, laid
## out flat is better in every direction. [HFlowContainer] wraps them when the
## screen is narrow, with no breakpoint involved.
func _build_palette_picker() -> void:
	if palettes.is_empty():
		_palette_section.hide()
		return

	for palette: UIPalette in palettes:
		var button := UIButton.new()
		button.text = _label_for(palette)
		button.pressed.connect(_on_palette_pressed.bind(palette))
		_palette_row.add_child(button)
		_palette_buttons.append(button)

	_mark_active(_current_palette())


func _on_palette_pressed(palette: UIPalette) -> void:
	var theme_to_reskin := _theme_to_reskin()
	if theme_to_reskin != null:
		theme_to_reskin.palette = palette
	_mark_active(palette)
	palette_changed.emit(palette)


## The chosen palette reads as the primary action; the rest stay secondary.
func _mark_active(active: UIPalette) -> void:
	for index: int in _palette_buttons.size():
		var is_active: bool = index < palettes.size() and palettes[index] == active
		_palette_buttons[index].variation = (
			UIButton.Variation.PRIMARY if is_active else UIButton.Variation.SECONDARY
		)


func _theme_to_reskin() -> UITheme:
	return target_theme if target_theme != null else UITheme.find_in_ancestors(self)


func _current_palette() -> UIPalette:
	var theme_to_reskin := _theme_to_reskin()
	return theme_to_reskin.palette if theme_to_reskin != null else null


func _label_for(palette: UIPalette) -> String:
	if not palette.resource_name.is_empty():
		return palette.resource_name
	if palette.resource_path.is_empty():
		return "Palette"
	return palette.resource_path.get_file().get_basename().capitalize()
