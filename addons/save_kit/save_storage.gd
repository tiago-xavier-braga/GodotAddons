@abstract
class_name SaveStorage
extends RefCounted

## Keeps the save's JSON text under a key. To save through an SDK, extend it and point the
## [code]save_kit/custom_storage[/code] project setting at the new script.


## Returns the text kept under [param key], or an empty string when there is none.
@abstract func read(key: String) -> String


## Returns false when the text couldn't be kept, so [code]SaveKit[/code] can warn.
@abstract func write(key: String, text: String) -> bool
