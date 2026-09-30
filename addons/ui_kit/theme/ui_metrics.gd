class_name UIMetrics
extends RefCounted

## Geometry constants shared by the theme builder and the menu templates.
##
## They live here, and not inside [UIThemeBuilder], because a template that
## sets [member Control.custom_minimum_size] by hand has to agree with the
## padding the theme draws — two copies of "44" would drift apart.

## Corner rounding applied to every filled style box.
const CORNER_RADIUS := 6

## Border thickness of a normal style box.
const BORDER_WIDTH := 2

## Border thickness of the focus ring, drawn over the normal style box.
const FOCUS_BORDER_WIDTH := 3

## Horizontal and vertical padding inside a button.
const BUTTON_PADDING_H := 20
const BUTTON_PADDING_V := 10

## Padding inside a panel.
const PANEL_PADDING := 16

## Gap between an icon and its label, and between check box and label.
const ICON_SEPARATION := 8

## Gap between stacked controls in the templates.
const CONTENT_SEPARATION := 12

## Gap between major sections in the templates.
const SECTION_SEPARATION := 24

## Smallest side of anything a finger has to hit. 44 px is the figure both
## Apple's and Google's guidelines land on.
const MIN_TOUCH_TARGET := 44

## Thickness of a slider's track.
const SLIDER_THICKNESS := 6

## Diameter of a slider's grabber knob.
const GRABBER_DIAMETER := 22

## How much a style box lightens on hover and darkens while pressed.
const HOVER_LIGHTEN := 0.12
const PRESSED_DARKEN := 0.12

## Opacity of a disabled control.
const DISABLED_ALPHA := 0.4

## Opacity of the tint behind a modal menu, such as the pause screen.
const SCRIM_ALPHA := 0.7
