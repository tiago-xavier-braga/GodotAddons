class_name UIBreakpoint
extends RefCounted

## The size classes [code]UIBreakpoints[/code] reports.
##
## These are [StringName]s rather than an enum — unlike [UIInputDevice], where
## the set of devices is closed. A project that wants a fourth class ("tablet",
## "ultrawide") can emit and match on its own name without editing the addon,
## and the constants here keep the common three out of string literals.
##
## This is never instantiated.

## Taller than wide, and small. Rows have to become columns.
const MOBILE_PORTRAIT := &"mobile_portrait"

## Wider than tall, but still small. Rows fit; vertical space does not.
const MOBILE_LANDSCAPE := &"mobile_landscape"

## Room for the layout as authored.
const DESKTOP := &"desktop"

const ALL: Array[StringName] = [MOBILE_PORTRAIT, MOBILE_LANDSCAPE, DESKTOP]


## True for either mobile class. Most layout decisions only care about "is this
## a phone", not which way it is held.
##
## The parameter is not called [code]breakpoint[/code] because that is a
## GDScript keyword.
static func is_mobile(size_class: StringName) -> bool:
	return size_class == MOBILE_PORTRAIT or size_class == MOBILE_LANDSCAPE
