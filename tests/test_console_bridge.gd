extends SceneTree

var failures := 0
const CHANNEL := "evil-wizard-console/v1"

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    if change_scene_to_file("res://scenes/MovementLab.tscn") != OK:
        printerr("FAIL: Movement Lab could not load")
        quit(1)
        return
    await process_frame
    await process_frame
    var bridge: ConsoleInputBridge = current_scene.get_node_or_null("ConsoleInputBridge") as ConsoleInputBridge
    _check(bridge != null, "console bridge exists in Movement Lab")
    if bridge == null:
        quit(1)
        return
    bridge.call("_receive_payload", {"channel": CHANNEL, "kind": "init"})
    _message(bridge, "move_right", true, "stick-right")
    _message(bridge, "move_right", true, "dpad-right")
    _message(bridge, "jump", true, "jump-finger")
    _message(bridge, "attack", true, "attack-finger")
    _check(Input.is_action_pressed("move_right"), "independent stick and dpad movement")
    _check(Input.is_action_pressed("jump"), "jump while moving")
    _check(Input.is_action_pressed("attack"), "attack while moving")
    _message(bridge, "move_right", false, "stick-right")
    _check(Input.is_action_pressed("move_right"), "releasing one right pointer preserves the other")
    _message(bridge, "move_right", false, "dpad-right")
    _check(not Input.is_action_pressed("move_right"), "last movement pointer releases")
    _message(bridge, "jump", false, "jump-finger")
    _check(not Input.is_action_pressed("jump"), "jump releases independently")
    _check(Input.is_action_pressed("attack"), "attack stays held after jump release")
    _message(bridge, "attack", false, "attack-finger")
    _check(not Input.is_action_pressed("attack"), "attack releases independently")
    _message(bridge, "attack", true, "attack-2")
    bridge.call("_receive_payload", {"channel": CHANNEL, "kind": "reset"})
    _check(not Input.is_action_pressed("attack"), "blur/reset releases all controls")
    _message(bridge, "not_a_game_action", true, "bad")
    _check(not InputMap.has_action("not_a_game_action"), "unknown action cannot be injected")
    if failures:
        printerr("%d console bridge checks failed" % failures)
        quit(1)
    else:
        print("Console bridge independent input test passed.")
        quit(0)

func _message(bridge: ConsoleInputBridge, action: String, pressed: bool, pointer: String) -> void:
    bridge.call("_receive_payload", {"channel": CHANNEL, "kind": "button", "action": action, "pressed": pressed, "pointer": pointer})

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures += 1
        printerr("FAIL: " + label)
