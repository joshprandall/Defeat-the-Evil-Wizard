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
    var hero: Hero = current_scene.get("player") as Hero
    _check(hero != null, "Movement Lab hero exists")
    if hero != null:
        hero.console_attack_queue = 0
    _message(bridge, "attack", true, "attack-finger")
    _check(Input.is_action_pressed("move_right"), "independent stick and dpad movement")
    _check(Input.is_action_pressed("jump"), "jump while moving")
    _check(hero != null and hero.console_attack_queue == 1, "handheld attack is queued independently of browser hold duration")
    _message(bridge, "move_right", false, "stick-right")
    _check(Input.is_action_pressed("move_right"), "releasing one right pointer preserves the other")
    _message(bridge, "move_right", false, "dpad-right")
    _check(not Input.is_action_pressed("move_right"), "last movement pointer releases")
    _message(bridge, "jump", false, "jump-finger")
    _check(not Input.is_action_pressed("jump"), "jump releases independently")
    _message(bridge, "attack", false, "attack-finger")
    _check(not Input.is_action_pressed("attack"), "handheld attack does not depend on a held Input action")
    if hero != null:
        hero.console_attack_queue = 0
    _message(bridge, "attack", true, "attack-2")
    _message(bridge, "attack", false, "attack-2")
    bridge.call("_receive_payload", {"channel": CHANNEL, "kind": "reset"})
    _check(hero != null and hero.console_attack_queue == 1, "reset does not erase an already queued attack tap")
    _message(bridge, "not_a_game_action", true, "bad")
    _check(not InputMap.has_action("not_a_game_action"), "unknown action cannot be injected")

    # Reproduce the iPhone failure mode: three extremely fast ATTACK taps whose
    # pointer-down/up pairs can all arrive between physics frames. They must be
    # retained as a three-hit Warrior combo and kill the starter Crawler.
    if hero != null:
        hero.reset_at(Vector2(180,560))
        hero.configure_class("warrior")
        hero.console_attack_queue = 0
        var enemy: RealmEnemy = RealmEnemy.new().setup("crawler",Vector2(236,560),hero)
        enemy.max_health = 50.0
        enemy.health = 50.0
        enemy.stun_time = 99.0
        current_scene.add_child(enemy)
        await physics_frame
        var starting_health: float = enemy.health
        for tap: int in range(3):
            var pointer: String = "rapid-attack-%d" % tap
            _message(bridge, "attack", true, pointer)
            _message(bridge, "attack", false, pointer)
        _check(hero.console_attack_queue == 3, "three rapid phone taps remain queued")
        for _frame: int in range(70):
            await physics_frame
            if not is_instance_valid(enemy) or enemy.health <= 0.0:
                break
        _check(not is_instance_valid(enemy) or enemy.health <= 0.0, "three rapid Warrior taps kill the 50 HP starter Crawler")
        _check(starting_health == 50.0, "starter Crawler regression uses onboarding health")

    bridge.call("_receive_payload", {
        "channel": CHANNEL,
        "kind": "controls",
        "keyboard": {"jump": 74, "attack": 75},
        "gamepad": {"jump": "button:3", "interact": "axis:5:1"}
    })
    _check(_has_key("jump",KEY_J), "keyboard remap replaces jump")
    _check(_has_key("attack",KEY_K), "keyboard remap replaces attack")
    _check(_has_button("jump",3), "controller remap replaces jump button")
    _check(_has_axis("interact",5,1.0), "controller remap replaces interact trigger")

    bridge.call("_receive_payload", {
        "channel": CHANNEL,
        "kind": "settings",
        "difficulty": "story",
        "camera_shake": false,
        "master_volume": 55
    })
    var master_bus: int = AudioServer.get_bus_index("Master")
    _check(master_bus >= 0, "Master audio bus exists")
    if master_bus >= 0:
        _check(not AudioServer.is_bus_mute(master_bus), "nonzero master volume is not muted")
        _check(absf(db_to_linear(AudioServer.get_bus_volume_db(master_bus)) - 0.55) < 0.03, "master volume setting applies")

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


func _has_key(action: StringName,key: Key) -> bool:
    for event: InputEvent in InputMap.action_get_events(action):
        if event is InputEventKey and (event as InputEventKey).physical_keycode == key:
            return true
    return false

func _has_button(action: StringName,index: int) -> bool:
    for event: InputEvent in InputMap.action_get_events(action):
        if event is InputEventJoypadButton and (event as InputEventJoypadButton).button_index == index:
            return true
    return false

func _has_axis(action: StringName,axis: int,value: float) -> bool:
    for event: InputEvent in InputMap.action_get_events(action):
        if event is InputEventJoypadMotion:
            var motion := event as InputEventJoypadMotion
            if motion.axis == axis and is_equal_approx(motion.axis_value,value):
                return true
    return false
