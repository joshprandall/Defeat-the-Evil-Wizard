extends SceneTree

var failures: int = 0

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
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
    controls.call("_touch_down", 4, buttons["crouch"])
    _check(Input.is_action_pressed("crouch"), "crouch from touch console")
    controls.call("_touch_up", 4)
    _check(not Input.is_action_pressed("crouch"), "crouch released")
    controls.call("_touch_down", 5, buttons["console"])
    _check(bool(controls.get("console_open")), "control console opens from touch")
    controls.call("_touch_down", 6, buttons["console"])
    _check(not bool(controls.get("console_open")), "control console closes from touch")
    controls.call("_release_all")
    lab.queue_free()
    await process_frame
    await process_frame
    if failures > 0:
        printerr("%d mobile touch checks failed" % failures)
        quit(1)
    else:
        print("Mobile touch input smoke test passed.")
        quit(0)

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures += 1
        printerr("FAIL: " + label)
