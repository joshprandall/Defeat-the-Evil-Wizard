extends SceneTree

var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var profile: Node = preload("res://scripts/input_profile.gd").new()
    profile.call("_ready")

    var game: Node = preload("res://scripts/game.gd").new()
    game.call("_install_gamepad_defaults")

    _check(_has_key("move_left",KEY_A),"keyboard A moves left")
    _check(_has_key("move_right",KEY_D),"keyboard D moves right")
    _check(_has_key("move_down",KEY_S) or _has_key("move_down",KEY_Q),"keyboard crouch is mapped")
    _check(_has_key("jump",KEY_W) or _has_key("jump",KEY_E),"keyboard W/E jumps")
    _check(_has_key("attack",KEY_SPACE) and _has_mouse("attack",MOUSE_BUTTON_LEFT),"Space and left mouse attack")
    _check(_has_key("interact",KEY_F),"keyboard F interacts")
    _check(_has_key("ultimate",KEY_U),"keyboard U uses ultimate")

    _check(_has_axis("move_left",0,-1.0),"left stick moves left")
    _check(_has_axis("move_right",0,1.0),"left stick moves right")
    _check(_has_axis("move_down",1,1.0),"left stick down crouches")
    _check(_has_button("move_left",13) and _has_button("move_right",14),"D-pad horizontal movement")
    _check(_has_button("move_down",12),"D-pad down crouches")
    _check(_has_button("jump",0),"Xbox A jumps")
    _check(_has_button("dash",1),"Xbox B dashes")
    _check(_has_button("attack",2),"Xbox X attacks")
    _check(_has_button("heavy_attack",3),"Xbox Y heavy attacks")
    _check(_has_button("ability_one",9) and _has_button("ability_two",10),"Xbox bumpers use abilities")
    _check(_has_axis("interact",4,1.0),"Xbox LT interacts")
    _check(_has_axis("ultimate",5,1.0),"Xbox RT uses ultimate")
    _check(_has_button("pause",6),"Xbox Menu/Start pauses")

    var player_source := FileAccess.get_file_as_string("res://scripts/player.gd")
    _check("Input.get_joy_axis(device,2)" in player_source and "Input.get_joy_axis(device,3)" in player_source,"right stick aiming is implemented")

    profile.queue_free()
    game.queue_free()

    if failures == 0:
        print("Desktop keyboard/mouse and Xbox-style gamepad input checks passed.")
        quit(0)
    printerr("%d input-mode checks failed." % failures)
    quit(1)

func _has_key(action: StringName,key: Key) -> bool:
    for event: InputEvent in InputMap.action_get_events(action):
        if event is InputEventKey and (event as InputEventKey).physical_keycode == key:
            return true
    return false

func _has_mouse(action: StringName,button: MouseButton) -> bool:
    for event: InputEvent in InputMap.action_get_events(action):
        if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == button:
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

func _check(condition: bool,label: String) -> void:
    if not condition:
        failures += 1
        printerr("FAIL: " + label)
