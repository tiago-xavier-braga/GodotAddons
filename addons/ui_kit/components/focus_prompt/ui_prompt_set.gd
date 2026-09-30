@tool
class_name UIPromptSet
extends Resource

## One glyph per input device, for [UIFocusPrompt] to draw.
##
## Keeping the glyphs in a resource instead of on the overlay is what makes
## switching to PlayStation or Switch artwork a one-field change, and it gives
## the "show nothing for this device" case a natural spelling: leave the slot
## empty. A project that finds focus prompts noisy for mouse players clears
## [member keyboard_mouse] and keeps the other two.

@export var keyboard_mouse: Texture2D
@export var gamepad: Texture2D
@export var touch: Texture2D


## The glyph for [param device], or [code]null[/code] when that device should
## show no prompt at all.
func glyph_for(device: UIInputDevice.Kind) -> Texture2D:
	match device:
		UIInputDevice.Kind.GAMEPAD:
			return gamepad
		UIInputDevice.Kind.TOUCH:
			return touch
		_:
			return keyboard_mouse
