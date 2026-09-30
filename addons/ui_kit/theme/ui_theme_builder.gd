class_name UIThemeBuilder
extends RefCounted

## Writes a [UIPalette] + [UITypography] pair into a [Theme].
##
## Godot's Theme Type Variations give you named styles ([code]UIPrimaryButton[/code]
## on top of [code]Button[/code]) but no way to share a color between them: every
## [StyleBoxFlat] stores its own hex. This builder is the missing half — one pass
## that derives every style box, color and font size in the theme from the tokens,
## so re-skinning a game is a few field edits in one resource.
##
## Only [method apply] is public. [UITheme] calls it whenever its tokens change;
## call it yourself if you keep a plain [Theme] around instead.

## Rebuilds [param theme] in place from [param palette] and [param typography].
##
## Everything already in [param theme] is cleared first, so calling this twice
## is the same as calling it once.
static func apply(theme: Theme, palette: UIPalette, typography: UITypography) -> void:
	if theme == null or palette == null or typography == null:
		return

	theme.clear()

	_apply_defaults(theme, palette, typography)
	_apply_buttons(theme, palette, typography)
	_apply_check_box(theme, palette, typography)
	_apply_sliders(theme, palette)
	_apply_panels(theme, palette)
	_apply_labels(theme, palette, typography)
	_apply_scroll_bars(theme, palette)


static func _apply_defaults(theme: Theme, palette: UIPalette, typography: UITypography) -> void:
	if typography.font_default != null:
		theme.default_font = typography.font_default
	theme.default_font_size = typography.size_body
	theme.default_base_scale = 1.0

	# Anything the kit does not style explicitly still needs a readable
	# background instead of the engine's grey.
	theme.set_stylebox(&"panel", &"PanelContainer", _filled(palette.background, 0))


static func _apply_buttons(theme: Theme, palette: UIPalette, typography: UITypography) -> void:
	# Base Button: a plain, script-free Button already looks like part of the
	# kit. The variations below only change emphasis.
	_write_button_set(theme, &"Button", typography, palette.surface, palette.text_primary, palette)

	theme.set_type_variation(UIVariants.PRIMARY_BUTTON, &"Button")
	_write_button_set(
		theme, UIVariants.PRIMARY_BUTTON, typography, palette.accent, palette.background, palette
	)

	# Secondary: outline only, so it reads as the quieter of two choices.
	theme.set_type_variation(UIVariants.SECONDARY_BUTTON, &"Button")
	_write_button_set(
		theme,
		UIVariants.SECONDARY_BUTTON,
		typography,
		Color(palette.accent, 0.0),
		palette.accent,
		palette,
		palette.accent
	)

	theme.set_type_variation(UIVariants.ICON_BUTTON, &"Button")
	_write_button_set(
		theme,
		UIVariants.ICON_BUTTON,
		typography,
		Color(palette.surface, 0.0),
		palette.text_primary,
		palette,
		Color(palette.text_secondary, 0.5)
	)
	# An icon button is square, so it gets even padding instead of a button's
	# wide horizontal padding.
	for state: StringName in [&"normal", &"hover", &"pressed", &"disabled", &"focus"]:
		var box: StyleBox = theme.get_stylebox(state, UIVariants.ICON_BUTTON)
		box.content_margin_left = UIMetrics.BUTTON_PADDING_V
		box.content_margin_right = UIMetrics.BUTTON_PADDING_V
	theme.set_constant(&"icon_max_width", UIVariants.ICON_BUTTON, UIMetrics.MIN_TOUCH_TARGET / 2)


## One [Button]-shaped type: five style boxes and the matching font and icon
## colors, all derived from [param background] and [param foreground].
static func _write_button_set(
	theme: Theme,
	type_name: StringName,
	typography: UITypography,
	background: Color,
	foreground: Color,
	palette: UIPalette,
	border_color: Color = Color(0, 0, 0, 0)
) -> void:
	var normal := _filled(background, UIMetrics.BORDER_WIDTH, border_color)
	normal.content_margin_left = UIMetrics.BUTTON_PADDING_H
	normal.content_margin_right = UIMetrics.BUTTON_PADDING_H
	normal.content_margin_top = UIMetrics.BUTTON_PADDING_V
	normal.content_margin_bottom = UIMetrics.BUTTON_PADDING_V

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = _hovered(background)
	hover.border_color = _hovered(border_color)

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = _pressed(background)
	pressed.border_color = _pressed(border_color)

	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = _dimmed(background)
	disabled.border_color = _dimmed(border_color)

	# The focus ring draws on top of whichever state box is current, so it is
	# border-only — filling it would erase the hover and pressed feedback.
	var focus := _outline(palette.text_primary)

	theme.set_stylebox(&"normal", type_name, normal)
	theme.set_stylebox(&"hover", type_name, hover)
	theme.set_stylebox(&"pressed", type_name, pressed)
	theme.set_stylebox(&"disabled", type_name, disabled)
	theme.set_stylebox(&"focus", type_name, focus)

	theme.set_font_size(&"font_size", type_name, typography.size_button)
	if typography.font_default != null:
		theme.set_font(&"font", type_name, typography.font_default)

	theme.set_color(&"font_color", type_name, foreground)
	theme.set_color(&"font_hover_color", type_name, _hovered(foreground))
	theme.set_color(&"font_pressed_color", type_name, _pressed(foreground))
	theme.set_color(&"font_hover_pressed_color", type_name, _pressed(foreground))
	theme.set_color(&"font_focus_color", type_name, foreground)
	theme.set_color(&"font_disabled_color", type_name, _dimmed(foreground))

	theme.set_color(&"icon_normal_color", type_name, foreground)
	theme.set_color(&"icon_hover_color", type_name, _hovered(foreground))
	theme.set_color(&"icon_pressed_color", type_name, _pressed(foreground))
	theme.set_color(&"icon_hover_pressed_color", type_name, _pressed(foreground))
	theme.set_color(&"icon_focus_color", type_name, foreground)
	theme.set_color(&"icon_disabled_color", type_name, _dimmed(foreground))

	theme.set_constant(&"h_separation", type_name, UIMetrics.ICON_SEPARATION)
	theme.set_constant(&"outline_size", type_name, 0)


static func _apply_check_box(theme: Theme, palette: UIPalette, typography: UITypography) -> void:
	# A check box has no filled background of its own — the tick is the whole
	# control — so every state box is empty except the focus ring.
	for state: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled"]:
		theme.set_stylebox(state, &"CheckBox", _padding(UIMetrics.BUTTON_PADDING_V))
	theme.set_stylebox(&"focus", &"CheckBox", _outline(palette.text_primary))

	# Godot 4 modulates the built-in tick glyphs with these two colors, so the
	# kit needs no check box textures of its own.
	theme.set_color(&"checkbox_checked_color", &"CheckBox", palette.accent)
	theme.set_color(&"checkbox_unchecked_color", &"CheckBox", palette.text_secondary)

	theme.set_color(&"font_color", &"CheckBox", palette.text_primary)
	theme.set_color(&"font_hover_color", &"CheckBox", _hovered(palette.text_primary))
	theme.set_color(&"font_pressed_color", &"CheckBox", palette.accent)
	theme.set_color(&"font_hover_pressed_color", &"CheckBox", palette.accent)
	theme.set_color(&"font_focus_color", &"CheckBox", palette.text_primary)
	theme.set_color(&"font_disabled_color", &"CheckBox", _dimmed(palette.text_primary))

	theme.set_font_size(&"font_size", &"CheckBox", typography.size_button)
	if typography.font_default != null:
		theme.set_font(&"font", &"CheckBox", typography.font_default)
	theme.set_constant(&"h_separation", &"CheckBox", UIMetrics.ICON_SEPARATION)


static func _apply_sliders(theme: Theme, palette: UIPalette) -> void:
	# The grabber is an icon, not a style box, and Godot does not modulate it.
	# Generating the texture from the palette keeps it in step with everything
	# else without shipping a knob sprite per color scheme.
	var grabber := _circle(UIMetrics.GRABBER_DIAMETER, palette.text_primary)
	var grabber_highlight := _circle(UIMetrics.GRABBER_DIAMETER, _hovered(palette.text_primary))
	var grabber_disabled := _circle(UIMetrics.GRABBER_DIAMETER, _dimmed(palette.text_primary))

	for type_name: StringName in [&"HSlider", &"VSlider"]:
		theme.set_stylebox(&"slider", type_name, _track(palette.background, palette.surface))
		theme.set_stylebox(&"grabber_area", type_name, _track(palette.accent, palette.accent))
		theme.set_stylebox(
			&"grabber_area_highlight", type_name, _track(_hovered(palette.accent), palette.accent)
		)
		theme.set_icon(&"grabber", type_name, grabber)
		theme.set_icon(&"grabber_highlight", type_name, grabber_highlight)
		theme.set_icon(&"grabber_disabled", type_name, grabber_disabled)
		theme.set_constant(&"center_grabber", type_name, 1)


static func _apply_panels(theme: Theme, palette: UIPalette) -> void:
	# Base Panel is the screen behind everything; UIPanel is a raised card on it.
	theme.set_stylebox(&"panel", &"Panel", _filled(palette.background, 0))

	theme.set_type_variation(UIVariants.PANEL, &"Panel")
	var card := _filled(palette.surface, UIMetrics.BORDER_WIDTH, _hovered(palette.surface))
	card.content_margin_left = UIMetrics.PANEL_PADDING
	card.content_margin_right = UIMetrics.PANEL_PADDING
	card.content_margin_top = UIMetrics.PANEL_PADDING
	card.content_margin_bottom = UIMetrics.PANEL_PADDING
	theme.set_stylebox(&"panel", UIVariants.PANEL, card)


static func _apply_labels(theme: Theme, palette: UIPalette, typography: UITypography) -> void:
	theme.set_color(&"font_color", &"Label", palette.text_primary)
	theme.set_font_size(&"font_size", &"Label", typography.size_body)
	if typography.font_default != null:
		theme.set_font(&"font", &"Label", typography.font_default)

	theme.set_type_variation(UIVariants.HEADING, &"Label")
	theme.set_color(&"font_color", UIVariants.HEADING, palette.text_primary)
	theme.set_font_size(&"font_size", UIVariants.HEADING, typography.size_heading)
	var heading_font: Font = typography.heading_font()
	if heading_font != null:
		theme.set_font(&"font", UIVariants.HEADING, heading_font)

	theme.set_type_variation(UIVariants.BODY, &"Label")
	theme.set_color(&"font_color", UIVariants.BODY, palette.text_primary)
	theme.set_font_size(&"font_size", UIVariants.BODY, typography.size_body)

	theme.set_type_variation(UIVariants.CAPTION, &"Label")
	theme.set_color(&"font_color", UIVariants.CAPTION, palette.text_secondary)
	theme.set_font_size(&"font_size", UIVariants.CAPTION, typography.size_caption)


static func _apply_scroll_bars(theme: Theme, palette: UIPalette) -> void:
	for type_name: StringName in [&"HScrollBar", &"VScrollBar"]:
		theme.set_stylebox(&"scroll", type_name, _track(palette.background, palette.background))
		theme.set_stylebox(&"scroll_focus", type_name, _track(palette.background, palette.accent))
		theme.set_stylebox(&"grabber", type_name, _track(palette.surface, palette.surface))
		theme.set_stylebox(
			&"grabber_highlight", type_name, _track(_hovered(palette.surface), palette.surface)
		)
		theme.set_stylebox(&"grabber_pressed", type_name, _track(palette.accent, palette.accent))


# --- style box factories ---


static func _filled(color: Color, border_width: int, border_color := Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(UIMetrics.CORNER_RADIUS)
	box.set_border_width_all(border_width)
	box.border_color = border_color
	box.anti_aliasing = true
	return box


## Border-only box, for a focus ring that must not hide the state underneath.
static func _outline(color: Color) -> StyleBoxFlat:
	var box := _filled(Color(color, 0.0), UIMetrics.FOCUS_BORDER_WIDTH, color)
	box.draw_center = false
	return box


## A slider or scroll bar track: thin, fully rounded, sized by its margins.
static func _track(color: Color, border_color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border_color
	box.set_corner_radius_all(UIMetrics.SLIDER_THICKNESS)
	box.content_margin_top = UIMetrics.SLIDER_THICKNESS / 2.0
	box.content_margin_bottom = UIMetrics.SLIDER_THICKNESS / 2.0
	box.content_margin_left = UIMetrics.SLIDER_THICKNESS / 2.0
	box.content_margin_right = UIMetrics.SLIDER_THICKNESS / 2.0
	box.anti_aliasing = true
	return box


## Invisible box that still reserves a touch-friendly hit area.
static func _padding(amount: int) -> StyleBoxEmpty:
	var box := StyleBoxEmpty.new()
	box.content_margin_left = amount
	box.content_margin_right = amount
	box.content_margin_top = amount
	box.content_margin_bottom = amount
	return box


# --- color derivation ---
#
# Hover, pressed and disabled are not tokens: they are the same token shifted.
# Deriving them keeps UIPalette down to the roles a designer actually names.


static func _hovered(color: Color) -> Color:
	return color.lightened(UIMetrics.HOVER_LIGHTEN)


static func _pressed(color: Color) -> Color:
	return color.darkened(UIMetrics.PRESSED_DARKEN)


static func _dimmed(color: Color) -> Color:
	return Color(color, color.a * UIMetrics.DISABLED_ALPHA)


## An anti-aliased filled circle, used for the slider grabbers.
static func _circle(diameter: int, color: Color) -> ImageTexture:
	var image := Image.create_empty(diameter, diameter, false, Image.FORMAT_RGBA8)
	var radius := diameter * 0.5
	var center := Vector2(radius, radius)
	for y: int in diameter:
		for x: int in diameter:
			# Distance to the edge, clamped to one pixel, is a cheap and
			# perfectly adequate coverage estimate at this size.
			var distance := Vector2(x + 0.5, y + 0.5).distance_to(center)
			var coverage := clampf(radius - distance, 0.0, 1.0)
			image.set_pixel(x, y, Color(color, color.a * coverage))
	return ImageTexture.create_from_image(image)
