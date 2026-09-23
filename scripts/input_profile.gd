extends Node

# One Input Map for desktop Web, standalone desktop, and the handheld build.
# Touch/console actions are unchanged; remap only conflicting keyboard keys.
# A/D move, S/Q crouch, W/E jump, Space/J/left click attack,
# K heavy, Shift dash, F interact, L/I abilities, U ultimate, Esc pause.

func _ready() -> void:
    _erase_key(&"jump", KEY_SPACE)
    _erase_key(&"dash", KEY_F)
    _erase_key(&"interact", KEY_E)
    _erase_key(&"ultimate", KEY_Q)

    _add_key(&"move_down", KEY_Q)
    _add_key(&"jump", KEY_W)
    _add_key(&"jump", KEY_E)
    _add_key(&"attack", KEY_SPACE)
    _add_key(&"interact", KEY_F)
    _add_key(&"ultimate", KEY_U)
    _add_mouse_attack()
    _add_mouse_heavy()

func _erase_key(action: StringName, key_code: int) -> void:
    if not InputMap.has_action(action):
        return
    for event: InputEvent in InputMap.action_get_events(action):
        if event is InputEventKey and (event as InputEventKey).physical_keycode == key_code:
            InputMap.action_erase_event(action, event)

func _add_key(action: StringName, key_code: int) -> void:
    if not InputMap.has_action(action):
        return
    for event: InputEvent in InputMap.action_get_events(action):
        if event is InputEventKey and (event as InputEventKey).physical_keycode == key_code:
            return
    var key_event := InputEventKey.new()
    key_event.physical_keycode = key_code
    InputMap.action_add_event(action, key_event)

func _add_mouse_attack() -> void:
    if not InputMap.has_action(&"attack"):
        return
    for event: InputEvent in InputMap.action_get_events(&"attack"):
        if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
            return
    var mouse_event := InputEventMouseButton.new()
    mouse_event.button_index = MOUSE_BUTTON_LEFT
    InputMap.action_add_event(&"attack", mouse_event)


func _add_mouse_heavy() -> void:
    if not InputMap.has_action(&"heavy_attack"):
        return
    for event: InputEvent in InputMap.action_get_events(&"heavy_attack"):
        if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
            return
    var mouse_event := InputEventMouseButton.new()
    mouse_event.button_index = MOUSE_BUTTON_RIGHT
    InputMap.action_add_event(&"heavy_attack", mouse_event)
