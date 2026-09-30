extends Control

## Phase 1 demo: nothing below the root has a script.
##
## Every control here is a stock [Panel], [Button], [CheckBox], [HSlider] or
## [Label] with a Theme Type Variation set in the inspector. Swapping the
## palette — here, or by editing [code]default_theme.tres[/code] while the
## editor is open — re-skins all of them, because [UITheme] rebuilds itself and
## the controls just redraw.

@export var palettes: Array[UIPalette] = []

@onready var _palette_name: Label = %PaletteName
@onready var _swap_button: Button = %SwapButton

var _index: int = 0


func _ready() -> void:
	_swap_button.pressed.connect(_on_swap_pressed)
	_apply_current()


func _on_swap_pressed() -> void:
	if palettes.is_empty():
		return
	_index = (_index + 1) % palettes.size()
	_apply_current()


func _apply_current() -> void:
	if palettes.is_empty():
		_palette_name.text = "No palettes assigned"
		return

	var ui_theme := theme as UITheme
	if ui_theme == null:
		_palette_name.text = "Root theme is not a UITheme"
		return

	var palette: UIPalette = palettes[_index]
	ui_theme.palette = palette
	_palette_name.text = "%s  (%d/%d)" % [
		palette.resource_name if not palette.resource_name.is_empty() else "unnamed",
		_index + 1,
		palettes.size(),
	]
