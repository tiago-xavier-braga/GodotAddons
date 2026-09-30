@tool
class_name UIButton
extends Button

## A [Button] that picks its Theme Type Variation from a dropdown, and
## guarantees a touch-sized hit area.
##
## Almost all of the kit is styling with no script behind it, and a plain
## [Button] with [member Control.theme_type_variation] set by hand is a fine
## way to use it. This exists for the two things a [Theme] cannot express:
##
## - A variation is a free-text string in the inspector, so a typo silently
##   falls back to the base style. An enum cannot be mistyped.
## - A theme sets padding, not a minimum size. Padding around a one-character
##   label still yields a target too small for a thumb, so the floor has to be
##   applied per node — see [constant UIMetrics.MIN_TOUCH_TARGET].

enum Variation {
	PRIMARY,
	SECONDARY,
	ICON,
}

const VARIATION_NAMES: Dictionary[int, StringName] = {
	Variation.PRIMARY: UIVariants.PRIMARY_BUTTON,
	Variation.SECONDARY: UIVariants.SECONDARY_BUTTON,
	Variation.ICON: UIVariants.ICON_BUTTON,
}

## Which variation to draw. Owns [member Control.theme_type_variation] —
## setting that by hand on a [UIButton] is overwritten.
@export var variation: Variation = Variation.PRIMARY:
	set(value):
		variation = value
		_apply_variation()


func _ready() -> void:
	_apply_variation()


func _apply_variation() -> void:
	theme_type_variation = VARIATION_NAMES[variation]

	# maxf, not assignment: a scene that asks for a bigger button keeps it.
	custom_minimum_size.y = maxf(custom_minimum_size.y, UIMetrics.MIN_TOUCH_TARGET)
	if variation == Variation.ICON:
		custom_minimum_size.x = maxf(custom_minimum_size.x, UIMetrics.MIN_TOUCH_TARGET)
