class_name UIInputDevice
extends RefCounted

## The kinds of device [code]UIInput[/code] can report, and their names.
##
## The enum lives in its own class rather than inside the autoload script,
## because GDScript refuses a [code]class_name[/code] that matches an autoload
## name — so [code]ui_input.gd[/code] cannot declare one, and a script with no
## [code]class_name[/code] cannot be used as a static type. This class is the
## type; [code]UIInput[/code] is the instance.
##
## This is never instantiated.

enum Kind {
	KEYBOARD_MOUSE,
	GAMEPAD,
	TOUCH,
}

const NAMES := {
	Kind.KEYBOARD_MOUSE: &"keyboard_mouse",
	Kind.GAMEPAD: &"gamepad",
	Kind.TOUCH: &"touch",
}


## A stable, lower-case name for [param kind] — for save files, analytics, or
## picking a glyph folder.
static func name_of(kind: Kind) -> StringName:
	return NAMES.get(kind, &"unknown")
