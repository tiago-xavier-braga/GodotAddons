@tool
class_name UITheme
extends Theme

## A [Theme] that generates itself from a [UIPalette] and a [UITypography].
##
## This is what a scene's [member Control.theme] points at. Assigning a
## different palette — in the inspector, or at runtime from the settings menu —
## rebuilds every style box through [UIThemeBuilder] and every control using
## this theme redraws. There is no "regenerate" button to remember.
##
## The saved [code].tres[/code] holds only the two token references; the theme
## items themselves are rebuilt on load, so the file stays small. Re-saving it
## from the resource inspector writes the generated items out too, which is
## harmless but pointless.

@export var palette: UIPalette:
	set(value):
		if palette == value:
			return
		_watch(palette, false)
		palette = value
		_watch(palette, true)
		_rebuild()

@export var typography: UITypography:
	set(value):
		if typography == value:
			return
		_watch(typography, false)
		typography = value
		_watch(typography, true)
		_rebuild()


## Rebuilds from the current tokens. Called for you when either token resource
## changes; useful by hand only if you mutated one without emitting
## [signal Resource.changed].
func rebuild() -> void:
	_rebuild()


func _rebuild() -> void:
	UIThemeBuilder.apply(self, palette, typography)


## Editing a field inside the palette has to rebuild too, not just swapping the
## whole resource — so the theme follows each token resource's [signal
## Resource.changed] for as long as it holds it.
func _watch(resource: Resource, connecting: bool) -> void:
	if resource == null:
		return
	if connecting:
		if not resource.changed.is_connected(_rebuild):
			resource.changed.connect(_rebuild)
	elif resource.changed.is_connected(_rebuild):
		resource.changed.disconnect(_rebuild)
