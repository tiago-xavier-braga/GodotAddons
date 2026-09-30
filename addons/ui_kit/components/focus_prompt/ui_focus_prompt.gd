class_name UIFocusPrompt
extends CanvasLayer

## Draws the glyph for the active input device next to whatever has focus.
##
## Add one instance per screen — that is the whole setup. It is a single
## overlay rather than a script on every component, because the two facts it
## needs are both global: which device is active ([code]UIInput[/code]) and
## which [Control] has focus ([method Viewport.gui_get_focus_owner]). Pushing
## that into each button would mean every component re-implementing the same
## two subscriptions, and a project's own controls getting none of it.
##
## Leave a slot empty in the [UIPromptSet] to show no prompt for that device.

## Glyph artwork, one per device.
@export var prompts: UIPromptSet

## Side length of the glyph, in pixels.
@export_range(8, 128, 1) var glyph_size: int = 28:
	set(value):
		glyph_size = value
		_reposition()

## Gap between the focused control's edge and the glyph.
@export_range(0, 64, 1) var gap: float = 8.0:
	set(value):
		gap = value
		_reposition()

var _glyph: TextureRect
var _target: Control


func _ready() -> void:
	# The pause menu is focusable while the tree is paused, and so is its
	# prompt.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_glyph = TextureRect.new()
	_glyph.name = "Glyph"
	_glyph.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# The overlay must never eat a click meant for the control underneath it.
	_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glyph.visible = false
	add_child(_glyph)

	UIInput.device_changed.connect(_on_device_changed)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)

	_target = get_viewport().gui_get_focus_owner()
	_refresh_texture()


func _process(_delta: float) -> void:
	# gui_focus_changed fires when a control *gains* focus, and nothing fires
	# when focus is dropped — so the owner is re-read here rather than trusted
	# to the signal alone. This also keeps the glyph attached to a control that
	# moves, whether from a scroll, a resize or a breakpoint change.
	var owner_now: Control = get_viewport().gui_get_focus_owner()
	if owner_now != _target:
		_target = owner_now
	_reposition()


func _on_device_changed(_device: UIInputDevice.Kind) -> void:
	_refresh_texture()


func _on_focus_changed(control: Control) -> void:
	_target = control
	_reposition()


func _refresh_texture() -> void:
	if _glyph == null:
		return
	_glyph.texture = prompts.glyph_for(UIInput.get_active_device()) if prompts != null else null
	_reposition()


func _reposition() -> void:
	if _glyph == null:
		return

	if _target == null or not _target.is_inside_tree() or not _target.is_visible_in_tree():
		_glyph.visible = false
		return
	if _glyph.texture == null:
		_glyph.visible = false
		return

	var rect: Rect2 = _target.get_global_rect()
	var side := float(glyph_size)
	var top := rect.position.y + (rect.size.y - side) * 0.5

	# Sit to the right of the control, unless that would leave the screen — a
	# menu anchored to the right edge is the common case.
	var left := rect.end.x + gap
	if left + side > get_viewport().get_visible_rect().size.x:
		left = rect.position.x - gap - side

	_glyph.position = Vector2(left, top)
	_glyph.size = Vector2(side, side)
	# Borrowing the focused control's own text color keeps the glyph in step
	# with the palette without the overlay needing a theme of its own.
	_glyph.modulate = (
		_target.get_theme_color(&"font_color")
		if _target.has_theme_color(&"font_color")
		else Color.WHITE
	)
	_glyph.visible = true
