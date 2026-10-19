class_name SaveWebStorage
extends SaveStorage

## Keeps the save in the browser's localStorage. It writes at once, while user:// on the web only
## reaches the browser's storage a moment after the file closes.

const HELPER_NAME: String = "saveKitStorage"
# localStorage throws when the browser blocks it or it's full; the helper returns "" or false
# instead, so the game keeps running.
const HELPER_SCRIPT: String = """
window.%s = {
	read: function (key) {
		try { return localStorage.getItem(key) || ""; } catch (error) { return ""; }
	},
	write: function (key, text) {
		try { localStorage.setItem(key, text); return true; } catch (error) { return false; }
	},
};
"""

var _helper: JavaScriptObject = null


func _init() -> void:
	JavaScriptBridge.eval(HELPER_SCRIPT % HELPER_NAME)
	_helper = JavaScriptBridge.get_interface(HELPER_NAME)


func read(key: String) -> String:
	return _helper.call("read", key)


func write(key: String, text: String) -> bool:
	return _helper.call("write", key, text)
