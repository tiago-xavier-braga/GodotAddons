class_name UIVariants
extends RefCounted

## Names of the Theme Type Variations that [UIThemeBuilder] generates.
##
## Variation names are plain strings inside a [Theme], and a [Theme] merged
## into a project's own one shares that namespace — so they carry the addon's
## [code]UI[/code] prefix like every other public name here. Referencing them
## through these constants means a rename is one edit, not a grep.

const PRIMARY_BUTTON := &"UIPrimaryButton"
const SECONDARY_BUTTON := &"UISecondaryButton"
const ICON_BUTTON := &"UIIconButton"

const PANEL := &"UIPanel"

const HEADING := &"UIHeading"
const BODY := &"UIBody"
const CAPTION := &"UICaption"
