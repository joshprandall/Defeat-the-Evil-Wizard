extends SceneTree

var failures: int = 0

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    # These mappings must be the same in the desktop and handheld exports.
    _check(_has_key(&"jump", KEY_W) and _has_key(&"jump", KEY_E), "W/E jump")
    _check(not _has_key(&"jump", KEY_SPACE), "Space no longer conflicts with jump")
    _check(_has_key(&"move_down", KEY_S) and _has_key(&"move_down", KEY_Q), "S/Q crouch")
    _check(_has_key(&"attack", KEY_SPACE) and _has_key(&"attack", KEY_J), "Space/J light attack")
    _check(_has_mouse_attack(), "Left mouse light attack")
    _check(_has_key(&"interact", KEY_F) and not _has_key(&"interact", KEY_E), "F interact; E reserved for jump")
    _check(_has_key(&"ultimate", KEY_U) and not _has_key(&"ultimate", KEY_Q), "U ultimate; Q reserved for crouch")
    _check(not _has_key(&"dash", KEY_F), "F does not trigger dash and interact together")

    if change_scene_to_file("res://scenes/MovementLab.tscn") != OK:
        printerr("FAIL: cannot load Movement Lab")
        quit(1)
        return
    await process_frame
    await process_frame
    var lab: Node = current_scene
    if lab == null:
        printerr("FAIL: Movement Lab has no current scene")
        quit(1)
        return
    var controls: Control = lab.get_node_or_null("MobileTouchLayer/MobileTouchControls") as Control
    if controls == null:
        printerr("FAIL: touch overlay is absent")
        quit(1)
        return
    controls.set("preview_on_desktop", true)
    await process_frame
    _check(controls.visible, "preview overlay should be visible during play")
    if not controls.visible:
        quit(1)
        return

    var stick_center: Vector2 = controls.call("_joystick_center")
    var buttons: Dictionary = controls.call("_buttons")
    controls.call("_touch_down", 1, stick_center + Vector2(58.0, 0.0))
    _check(Input.is_action_pressed("move_right"), "right movement from left thumb")
    controls.call("_touch_down", 2, buttons["jump"])
    controls.call("_touch_down", 3, buttons["attack"])
    _check(Input.is_action_pressed("move_right"), "movement retained during multitouch")
    _check(Input.is_action_pressed("jump"), "jump from second finger")
    _check(Input.is_action_pressed("attack"), "attack from third finger")
    controls.call("_touch_up", 2)
    _check(not Input.is_action_pressed("jump"), "jump released independently")
    _check(Input.is_action_pressed("attack"), "attack remains held")
    controls.call("_touch_up", 3)
    controls.call("_touch_up", 1)
    _check(not Input.is_action_pressed("attack"), "attack released")
    _check(not Input.is_action_pressed("move_right"), "movement released")
    controls.call("_release_all")

    # Facebook and other iOS WebViews can refuse to rotate even when the device
    # is physically sideways. Test the production layout math against an
    # explicit iPhone-sized portrait viewport; headless Godot itself keeps the
    # configured project stretch size and cannot emulate this by resizing Window.
    var portrait_size := Vector2(393,852)
    _check(bool(controls.call("_portrait_for",portrait_size)), "portrait compatibility mode is detected")
    var portrait_stick: Vector2 = controls.call("_joystick_center_for",portrait_size)
    var portrait_buttons: Dictionary = controls.call("_buttons_for",portrait_size)
    _check(portrait_stick.x >= 0.0 and portrait_stick.x <= portrait_size.x and portrait_stick.y >= 0.0 and portrait_stick.y <= portrait_size.y, "portrait joystick stays on-screen")
    for action: String in ["attack","jump","heavy_attack","dash","interact","ability_one","ability_two","ultimate","pause"]:
        var p: Vector2 = portrait_buttons[action]
        _check(p.x >= 0.0 and p.x <= portrait_size.x and p.y >= 0.0 and p.y <= portrait_size.y, "portrait %s control stays on-screen" % action)

    if failures > 0:
        printerr("%d input checks failed" % failures)
        quit(1)
    else:
        print("Desktop input map and independent mobile touch smoke test passed.")
        quit(0)

func _has_key(action: StringName, key_code: int) -> bool:
    for event: InputEvent in InputMap.action_get_events(action):
        if event is InputEventKey and (event as InputEventKey).physical_keycode == key_code:
            return true
    return false

func _has_mouse_attack() -> bool:
    for event: InputEvent in InputMap.action_get_events(&"attack"):
        if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
            return true
    return false

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures += 1
        printerr("FAIL: " + label)
