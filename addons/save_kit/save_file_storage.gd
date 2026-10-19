class_name SaveFileStorage
extends SaveStorage

const PATH_FORMAT: String = "user://%s.json"

func read(key: String) -> String:
	var path: String = PATH_FORMAT % key
	if not FileAccess.file_exists(path):
		return ""
	return FileAccess.get_file_as_string(path)


# Straight to the file: a save this small isn't worth a temp file and a rename yet.
func write(key: String, text: String) -> bool:
	var file: FileAccess = FileAccess.open(PATH_FORMAT % key, FileAccess.WRITE)
	return file != null and file.store_string(text)
