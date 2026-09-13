class_name SaveSystem
extends RefCounted

const SAVE_PATH: String = "user://last_road_save.json"
const SAVE_VERSION: int = 1

static func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

static func save_game(data: Dictionary) -> bool:
    var payload: Dictionary = data.duplicate(true)
    payload["save_version"] = SAVE_VERSION
    var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(payload, "\t"))
    file.close()
    return true

static func load_game() -> Dictionary:
    if not has_save():
        return {}
    var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return {}
    var raw: String = file.get_as_text()
    file.close()
    var parsed: Variant = JSON.parse_string(raw)
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    var data: Dictionary = parsed
    if int(data.get("save_version", 0)) != SAVE_VERSION:
        return {}
    return data

static func clear_save() -> void:
    if has_save():
        DirAccess.remove_absolute(SAVE_PATH)
