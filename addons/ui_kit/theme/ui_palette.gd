@tool
class_name UIPalette
extends Resource

## Semantic color tokens for the whole kit.
##
## Components never name a color — they ask for a role (accent, surface,
## text_primary, ...). Swapping this resource re-skins everything, because
## [UITheme] rebuilds itself whenever the palette emits [signal Resource.changed].

const DEFAULT_BACKGROUND := Color("001219")
const DEFAULT_SURFACE := Color("005f73")
const DEFAULT_TEXT_PRIMARY := Color("e9d8a6")
const DEFAULT_TEXT_SECONDARY := Color("94d2bd")
const DEFAULT_ACCENT := Color("ee9b00")
const DEFAULT_INFO := Color("0a9396")
const DEFAULT_WARNING := Color("ca6702")
const DEFAULT_ERROR := Color("bb3e03")
const DEFAULT_CRITICAL := Color("9b2226")

@export_group("Surfaces")
@export var background: Color = DEFAULT_BACKGROUND:
	set(value):
		background = value
		emit_changed()

@export var surface: Color = DEFAULT_SURFACE:
	set(value):
		surface = value
		emit_changed()

@export_group("Text")
@export var text_primary: Color = DEFAULT_TEXT_PRIMARY:
	set(value):
		text_primary = value
		emit_changed()

@export var text_secondary: Color = DEFAULT_TEXT_SECONDARY:
	set(value):
		text_secondary = value
		emit_changed()

@export_group("Action")
@export var accent: Color = DEFAULT_ACCENT:
	set(value):
		accent = value
		emit_changed()

@export_group("Severity")
@export var info: Color = DEFAULT_INFO:
	set(value):
		info = value
		emit_changed()

@export var warning: Color = DEFAULT_WARNING:
	set(value):
		warning = value
		emit_changed()

@export var error: Color = DEFAULT_ERROR:
	set(value):
		error = value
		emit_changed()

@export var critical: Color = DEFAULT_CRITICAL:
	set(value):
		critical = value
		emit_changed()


## The severity ramp in order, for anything that maps a level onto a color.
func severity_ramp() -> PackedColorArray:
	return PackedColorArray([info, warning, error, critical])
