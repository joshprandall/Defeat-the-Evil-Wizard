extends Control

# Multi-finger controls for the landscape web/mobile game.
# The desktop keyboard and gamepad actions remain available alongside this overlay.
@export var preview_on_desktop: bool = false

const INK := Color(0.12, 0.14, 0.18, 0.98)
const LIGHT_INK := Color(0.94, 0.93, 0.89, 0.98)
const RIM := Color(0.68, 0.71, 0.74, 0.96)
const FILL := Color(0.78, 0.79, 0.79, 0.94)
const HELD_FILL := Color(0.96, 0.70, 0.39, 0.98)
const PANEL := Color(0.035, 0.045, 0.065, 0.96)
const ACTIONS := ["jump", "attack", "heavy_attack", "dash", "crouch", "interact", "ability_one", "ability_two", "ultimate", "pause"]

var joystick_finger: int = -1
var joystick_axis: Vector2 = Vector2.ZERO
var finger_actions: Dictionary = {}
var button_holds: Dictionary = {}
var stick_holds: Dictionary = {}
var muted_touch_mouse: bool = false
var original_mouse_emulation: bool = true
var console_open: bool = false
var font: Font

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    process_mode = Node.PROCESS_MODE_ALWAYS
    font = ThemeDB.fallback_font
    original_mouse_emulation = Input.is_emulating_mouse_from_touch()
    visible = false
    set_process_input(true)

func _exit_tree() -> void:
    _release_all()
    if muted_touch_mouse:
        Input.set_emulate_mouse_from_touch(original_mouse_emulation)
        muted_touch_mouse = false

func _process(_delta: float) -> void:
    var active: bool = _gameplay_active()
    if not active and visible:
        _release_all()
    visible = active
    if active and not muted_touch_mouse:
        original_mouse_emulation = Input.is_emulating_mouse_from_touch()
        Input.set_emulate_mouse_from_touch(false)
        muted_touch_mouse = true
    elif not active and muted_touch_mouse:
        Input.set_emulate_mouse_from_touch(original_mouse_emulation)
        muted_touch_mouse = false
    if active:
        queue_redraw()

func _gameplay_active() -> bool:
    if not (preview_on_desktop or DisplayServer.is_touchscreen_available()):
        return false
    if get_tree().paused:
        return false
    var scene: Node = get_tree().current_scene
    if scene == null or scene.get("player") == null:
        return false
    if scene.name == "Game":
        var game_hud: GameHUD = scene.get("hud") as GameHUD
        if game_hud == null:
            return false
        if game_hud.title_overlay.visible or game_hud.pause_overlay.visible or game_hud.victory_overlay.visible:
            return false
        if game_hud.shrine_overlay.visible or game_hud.dialogue_panel.visible or bool(scene.get("cutscene_active")):
            return false
    return true

func _portrait() -> bool:
    var viewport_size: Vector2 = get_viewport_rect().size
    return viewport_size.y > viewport_size.x

func _scale() -> float:
    var viewport_size: Vector2 = get_viewport_rect().size
    return clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.60, 1.25)

func _joystick_center() -> Vector2:
    var viewport_size: Vector2 = get_viewport_rect().size
    var factor: float = _scale()
    return Vector2(155.0 * factor, viewport_size.y - 135.0 * factor)

func _buttons() -> Dictionary:
    var viewport_size: Vector2 = get_viewport_rect().size
    var factor: float = _scale()
    return {
        "attack": Vector2(viewport_size.x - 117.0 * factor, viewport_size.y - 119.0 * factor),
        "jump": Vector2(viewport_size.x - 226.0 * factor, viewport_size.y - 81.0 * factor),
        "crouch": Vector2(viewport_size.x - 226.0 * factor, viewport_size.y - 185.0 * factor),
        "heavy_attack": Vector2(viewport_size.x - 71.0 * factor, viewport_size.y - 224.0 * factor),
        "dash": Vector2(viewport_size.x - 332.0 * factor, viewport_size.y - 156.0 * factor),
        "interact": Vector2(viewport_size.x - 197.0 * factor, viewport_size.y - 242.0 * factor),
        "ability_one": Vector2(viewport_size.x - 317.0 * factor, viewport_size.y - 289.0 * factor),
        "ability_two": Vector2(viewport_size.x - 433.0 * factor, viewport_size.y - 238.0 * factor),
        "ultimate": Vector2(viewport_size.x - 91.0 * factor, viewport_size.y - 346.0 * factor),
        "pause": Vector2(viewport_size.x - 44.0 * factor, 43.0 * factor),
        "console": Vector2(48.0 * factor, 43.0 * factor),
    }

func _button_size(action: String) -> Vector2:
    var factor: float = _scale()
    var side: float = 72.0
    if action == "attack" or action == "jump":
        side = 88.0
    elif action == "pause" or action == "console":
        side = 54.0
    return Vector2(side, side) * factor

func _radius(action: String) -> float:
    return maxf(_button_size(action).x, _button_size(action).y) * 0.56

func _input(event: InputEvent) -> void:
    if not visible:
        return
    if event is InputEventKey:
        var key_event: InputEventKey = event
        if key_event.pressed and not key_event.echo and (key_event.physical_keycode == KEY_QUOTELEFT or key_event.physical_keycode == KEY_BACKSLASH):
            console_open = not console_open
            get_viewport().set_input_as_handled()
            return
    if event is InputEventScreenTouch:
        var touch: InputEventScreenTouch = event
        if _portrait():
            get_viewport().set_input_as_handled()
            return
        if touch.pressed:
            _touch_down(touch.index, touch.position)
        else:
            _touch_up(touch.index)
    elif event is InputEventScreenDrag:
        var drag: InputEventScreenDrag = event
        if drag.index == joystick_finger:
            _update_joystick(drag.position)
            get_viewport().set_input_as_handled()
        elif finger_actions.has(drag.index):
            get_viewport().set_input_as_handled()

func _touch_down(finger: int, at: Vector2) -> void:
    var positions: Dictionary = _buttons()
    if at.distance_to(positions["console"]) <= _radius("console") * 1.25:
        console_open = not console_open
        get_viewport().set_input_as_handled()
        return
    if joystick_finger == -1 and at.distance_to(_joystick_center()) < 104.0 * _scale():
        joystick_finger = finger
        _update_joystick(at)
        get_viewport().set_input_as_handled()
        return
    for action: String in ACTIONS:
        if at.distance_to(positions[action]) <= _radius(action) * 1.17:
            if action == "pause":
                _pause_game()
            else:
                finger_actions[finger] = action
                button_holds[action] = int(button_holds.get(action, 0)) + 1
                Input.action_press(action)
            get_viewport().set_input_as_handled()
            return

func _touch_up(finger: int) -> void:
    if finger == joystick_finger:
        joystick_finger = -1
        _apply_stick(Vector2.ZERO)
        get_viewport().set_input_as_handled()
    elif finger_actions.has(finger):
        var action: String = str(finger_actions[finger])
        finger_actions.erase(finger)
        var count: int = maxi(0, int(button_holds.get(action, 0)) - 1)
        button_holds[action] = count
        if count == 0:
            Input.action_release(action)
        get_viewport().set_input_as_handled()

func _update_joystick(at: Vector2) -> void:
    _apply_stick((at - _joystick_center()) / (76.0 * _scale()))

func _apply_stick(raw: Vector2) -> void:
    joystick_axis = raw.limit_length(1.0)
    _stick_action("move_left", joystick_axis.x < -0.26, absf(joystick_axis.x))
    _stick_action("move_right", joystick_axis.x > 0.26, absf(joystick_axis.x))
    _stick_action("move_up", joystick_axis.y < -0.48, -joystick_axis.y)
    _stick_action("move_down", joystick_axis.y > 0.48, joystick_axis.y)

func _stick_action(action: String, pressed: bool, strength: float) -> void:
    if pressed:
        Input.action_press(action, strength)
        stick_holds[action] = true
    elif stick_holds.has(action):
        Input.action_release(action)
        stick_holds.erase(action)

func _release_all() -> void:
    _apply_stick(Vector2.ZERO)
    joystick_finger = -1
    for action: String in button_holds.keys():
        Input.action_release(action)
    button_holds.clear()
    finger_actions.clear()
    console_open = false

func _pause_game() -> void:
    var scene: Node = get_tree().current_scene
    if scene != null and scene.name == "Game":
        var game_hud: GameHUD = scene.get("hud") as GameHUD
        if game_hud != null:
            game_hud.pause_toggled.emit()
    elif scene != null and scene.name == "MovementLab":
        _release_all()
        get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _draw() -> void:
    var viewport_size := get_viewport_rect().size
    var factor: float = _scale()
    if _portrait():
        draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.02, 0.03, 0.05, 0.90))
        draw_string(font, Vector2(0.0, viewport_size.y * 0.5), "ROTATE PHONE TO PLAY", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 22, LIGHT_INK)
        return

    var stick: Vector2 = _joystick_center()
    draw_circle(stick, 89.0 * factor, Color(0.10, 0.12, 0.16, 0.62))
    draw_arc(stick, 89.0 * factor, 0.0, TAU, 48, RIM, 3.0 * factor, true)
    draw_circle(stick + joystick_axis * 60.0 * factor, 34.0 * factor, Color(0.42, 0.45, 0.49, 0.92))
    draw_arc(stick + joystick_axis * 60.0 * factor, 34.0 * factor, 0.0, TAU, 32, LIGHT_INK, 2.0 * factor, true)
    _draw_dpad_hint(stick, factor)

    var positions: Dictionary = _buttons()
    for action: String in ACTIONS:
        var p: Vector2 = positions[action]
        var held: bool = int(button_holds.get(action, 0)) > 0
        _draw_button(action, p, held)
    _draw_button("console", positions["console"], console_open)
    if console_open:
        _draw_console(viewport_size, factor)

func _draw_dpad_hint(center: Vector2, factor: float) -> void:
    var ink := Color(0.9, 0.91, 0.92, 0.85)
    draw_line(center + Vector2(-28,0) * factor, center + Vector2(28,0) * factor, ink, 5.0 * factor, true)
    draw_line(center + Vector2(0,-28) * factor, center + Vector2(0,28) * factor, ink, 5.0 * factor, true)

func _draw_button(action: String, p: Vector2, held: bool) -> void:
    var size: Vector2 = _button_size(action)
    var box := StyleBoxFlat.new()
    box.bg_color = HELD_FILL if held else FILL
    box.border_color = INK if held else RIM
    box.set_border_width_all(maxi(2, int(3.0 * _scale())))
    box.corner_radius_top_left = int(12.0 * _scale())
    box.corner_radius_top_right = int(12.0 * _scale())
    box.corner_radius_bottom_left = int(12.0 * _scale())
    box.corner_radius_bottom_right = int(12.0 * _scale())
    draw_style_box(box, Rect2(p - size * 0.5, size))
    _draw_icon(action, p, _scale())

func _draw_console(viewport_size: Vector2, factor: float) -> void:
    var panel_size := Vector2(minf(500.0 * factor, viewport_size.x - 120.0 * factor), 248.0 * factor)
    var panel_pos := Vector2(60.0 * factor, 78.0 * factor)
    var box := StyleBoxFlat.new()
    box.bg_color = PANEL
    box.border_color = RIM
    box.set_border_width_all(maxi(2, int(3.0 * factor)))
    box.corner_radius_top_left = int(14.0 * factor)
    box.corner_radius_top_right = int(14.0 * factor)
    box.corner_radius_bottom_left = int(14.0 * factor)
    box.corner_radius_bottom_right = int(14.0 * factor)
    draw_style_box(box, Rect2(panel_pos, panel_size))
    var x := panel_pos.x + 22.0 * factor
    var y := panel_pos.y + 32.0 * factor
    draw_string(font, Vector2(x, y), "CONTROL CONSOLE", HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(21.0 * factor), LIGHT_INK)
    var rows := [
        "MOVE     W A S D / LEFT STICK",
        "JUMP     E / UP",
        "CROUCH   Q / DOWN",
        "ATTACK   SPACE / LEFT MOUSE",
        "DASH     SHIFT / X     INTERACT  F",
        "ABILITIES L / I        ULTIMATE  U",
        "CONSOLE  ` or this button"
    ]
    for row in rows:
        y += 27.0 * factor
        draw_string(font, Vector2(x, y), row, HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(14.0 * factor), LIGHT_INK)

func _draw_icon(action: String, p: Vector2, factor: float) -> void:
    var ink := INK
    if action == "attack":
        var points := PackedVector2Array([
            p + Vector2(-17,-8)*factor, p + Vector2(-10,-17)*factor,
            p + Vector2(-3,-14)*factor, p + Vector2(3,-17)*factor,
            p + Vector2(9,-13)*factor, p + Vector2(16,-13)*factor,
            p + Vector2(18,-3)*factor, p + Vector2(13,13)*factor,
            p + Vector2(-11,13)*factor, p + Vector2(-18,2)*factor,
        ])
        draw_colored_polygon(points, ink)
        for offset: int in [-8, 0, 8]:
            draw_line(p + Vector2(offset,-8)*factor, p + Vector2(offset,-2)*factor, FILL, 2.0*factor, true)
    elif action == "jump":
        draw_line(p + Vector2(0,17)*factor,p + Vector2(0,-15)*factor,ink,5.0*factor,true)
        draw_line(p + Vector2(-13,-2)*factor,p + Vector2(0,-15)*factor,ink,5.0*factor,true)
        draw_line(p + Vector2(13,-2)*factor,p + Vector2(0,-15)*factor,ink,5.0*factor,true)
    elif action == "crouch":
        draw_line(p + Vector2(-14,-8)*factor,p + Vector2(0,9)*factor,ink,5.0*factor,true)
        draw_line(p + Vector2(14,-8)*factor,p + Vector2(0,9)*factor,ink,5.0*factor,true)
        draw_line(p + Vector2(-16,13)*factor,p + Vector2(16,13)*factor,ink,5.0*factor,true)
    elif action == "dash":
        for shift: int in [-7, 5]:
            draw_line(p + Vector2(shift-9,-12)*factor,p + Vector2(shift+3,0)*factor,ink,4.0*factor,true)
            draw_line(p + Vector2(shift+3,0)*factor,p + Vector2(shift-9,12)*factor,ink,4.0*factor,true)
    elif action == "heavy_attack":
        draw_line(p+Vector2(-15,15)*factor,p+Vector2(11,-12)*factor,ink,5.0*factor,true)
        draw_line(p+Vector2(4,-11)*factor,p+Vector2(16,0)*factor,ink,4.0*factor,true)
        draw_line(p+Vector2(-19,5)*factor,p+Vector2(-6,18)*factor,ink,4.0*factor,true)
    elif action == "pause":
        draw_line(p+Vector2(-6,-11)*factor,p+Vector2(-6,11)*factor,ink,5.0*factor,true)
        draw_line(p+Vector2(6,-11)*factor,p+Vector2(6,11)*factor,ink,5.0*factor,true)
    elif action == "console":
        draw_line(p+Vector2(-13,-8)*factor,p+Vector2(13,-8)*factor,ink,4.0*factor,true)
        draw_line(p+Vector2(-13,0)*factor,p+Vector2(13,0)*factor,ink,4.0*factor,true)
        draw_line(p+Vector2(-13,8)*factor,p+Vector2(13,8)*factor,ink,4.0*factor,true)
    else:
        var symbol: String = "?"
        if action == "interact": symbol = "F"
        elif action == "ability_one": symbol = "L"
        elif action == "ability_two": symbol = "I"
        elif action == "ultimate": symbol = "U"
        draw_string(font, p + Vector2(-16,9)*factor, symbol, HORIZONTAL_ALIGNMENT_CENTER, 32.0*factor, maxi(15,int(25.0*factor)), ink)
