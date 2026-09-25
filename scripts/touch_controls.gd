extends Control

# On-screen, multi-finger controls for the landscape Web/mobile game.
# Existing keyboard/gamepad actions continue to work unchanged.
@export var preview_on_desktop: bool = false

const INK := Color(0.96, 0.91, 0.79, 0.95)
const RIM := Color(0.96, 0.70, 0.39, 0.84)
const FILL := Color(0.08, 0.11, 0.16, 0.68)
const HIGHLIGHT := Color(0.42, 0.24, 0.16, 0.86)
const ACTIONS := ["jump", "attack", "heavy_attack", "dash", "interact", "ability_one", "ability_two", "ultimate", "pause"]

var joystick_finger: int = -1
var joystick_axis: Vector2 = Vector2.ZERO
var finger_actions: Dictionary = {}
var button_holds: Dictionary = {}
var stick_holds: Dictionary = {}
var muted_touch_mouse: bool = false
var original_mouse_emulation: bool = true
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

func _portrait_for(viewport_size: Vector2) -> bool:
    return viewport_size.y > viewport_size.x

func _portrait() -> bool:
    return _portrait_for(get_viewport_rect().size)

func _scale_for(viewport_size: Vector2) -> float:
    return clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.60, 1.25)

func _scale() -> float:
    return _scale_for(get_viewport_rect().size)

func _joystick_center_for(viewport_size: Vector2) -> Vector2:
    var factor: float = _scale_for(viewport_size)
    if _portrait_for(viewport_size):
        return Vector2(142.0 * factor, viewport_size.y - 150.0 * factor)
    return Vector2(155.0 * factor, viewport_size.y - 135.0 * factor)

func _joystick_center() -> Vector2:
    return _joystick_center_for(get_viewport_rect().size)

func _buttons_for(viewport_size: Vector2) -> Dictionary:
    var factor: float = _scale_for(viewport_size)
    if _portrait_for(viewport_size):
        return {
            "attack": Vector2(viewport_size.x - 86.0 * factor, viewport_size.y - 118.0 * factor),
            "jump": Vector2(viewport_size.x - 205.0 * factor, viewport_size.y - 92.0 * factor),
            "heavy_attack": Vector2(viewport_size.x - 82.0 * factor, viewport_size.y - 238.0 * factor),
            "dash": Vector2(viewport_size.x - 205.0 * factor, viewport_size.y - 212.0 * factor),
            "interact": Vector2(viewport_size.x - 82.0 * factor, viewport_size.y - 358.0 * factor),
            "ability_one": Vector2(viewport_size.x - 205.0 * factor, viewport_size.y - 332.0 * factor),
            "ability_two": Vector2(viewport_size.x - 82.0 * factor, viewport_size.y - 478.0 * factor),
            "ultimate": Vector2(viewport_size.x - 205.0 * factor, viewport_size.y - 452.0 * factor),
            "pause": Vector2(viewport_size.x - 54.0 * factor, 54.0 * factor),
        }
    return {
        "attack": Vector2(viewport_size.x - 117.0 * factor, viewport_size.y - 119.0 * factor),
        "jump": Vector2(viewport_size.x - 226.0 * factor, viewport_size.y - 81.0 * factor),
        "heavy_attack": Vector2(viewport_size.x - 71.0 * factor, viewport_size.y - 224.0 * factor),
        "dash": Vector2(viewport_size.x - 332.0 * factor, viewport_size.y - 156.0 * factor),
        "interact": Vector2(viewport_size.x - 197.0 * factor, viewport_size.y - 242.0 * factor),
        "ability_one": Vector2(viewport_size.x - 317.0 * factor, viewport_size.y - 289.0 * factor),
        "ability_two": Vector2(viewport_size.x - 433.0 * factor, viewport_size.y - 238.0 * factor),
        "ultimate": Vector2(viewport_size.x - 91.0 * factor, viewport_size.y - 346.0 * factor),
        "pause": Vector2(viewport_size.x - 44.0 * factor, 43.0 * factor),
    }

func _buttons() -> Dictionary:
    return _buttons_for(get_viewport_rect().size)

func _radius(action: String) -> float:
    var base_radius: float = 42.0
    if action == "attack" or action == "jump":
        base_radius = 50.0
    elif action == "pause":
        base_radius = 26.0
    elif action == "ability_one" or action == "ability_two" or action == "ultimate" or action == "interact":
        base_radius = 34.0
    return base_radius * _scale()

func _input(event: InputEvent) -> void:
    if not visible:
        return
    if event is InputEventScreenTouch:
        var touch: InputEventScreenTouch = event
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
    if joystick_finger == -1 and at.distance_to(_joystick_center()) < 104.0 * _scale():
        joystick_finger = finger
        _update_joystick(at)
        get_viewport().set_input_as_handled()
        return
    var positions: Dictionary = _buttons()
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
    var viewport_size: Vector2 = get_viewport_rect().size
    var factor: float = _scale()
    if _portrait():
        draw_rect(Rect2(0,0,viewport_size.x,34.0*factor),Color(0.02,0.03,0.05,0.46))
        draw_string(font,Vector2(0,23.0*factor),"PORTRAIT COMPATIBILITY MODE  •  LANDSCAPE RECOMMENDED",HORIZONTAL_ALIGNMENT_CENTER,viewport_size.x,maxi(9,int(13.0*factor)),Color(0.92,0.88,0.76,0.82))
    var stick: Vector2 = _joystick_center()
    draw_circle(stick, 89.0 * factor, FILL)
    draw_arc(stick, 89.0 * factor, 0.0, TAU, 48, RIM, 3.0 * factor, true)
    draw_circle(stick + joystick_axis * 60.0 * factor, 34.0 * factor, HIGHLIGHT)
    draw_arc(stick + joystick_axis * 60.0 * factor, 34.0 * factor, 0.0, TAU, 32, INK, 2.0 * factor, true)
    var positions: Dictionary = _buttons()
    for action: String in ACTIONS:
        var p: Vector2 = positions[action]
        var radius: float = _radius(action)
        var held: bool = int(button_holds.get(action, 0)) > 0
        draw_circle(p, radius, HIGHLIGHT if held else FILL)
        draw_arc(p, radius, 0.0, TAU, 32, INK if held else RIM, 2.8 * factor, true)
        _draw_icon(action, p, factor)

func _draw_icon(action: String, p: Vector2, factor: float) -> void:
    var ink: Color = INK
    if action == "attack":
        # Four knuckles, thumb and wrist form a simple fist silhouette.
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
        draw_line(p + Vector2(0,16)*factor,p + Vector2(0,-15)*factor,ink,5.0*factor,true)
        draw_line(p + Vector2(-13,-2)*factor,p + Vector2(0,-15)*factor,ink,5.0*factor,true)
        draw_line(p + Vector2(13,-2)*factor,p + Vector2(0,-15)*factor,ink,5.0*factor,true)
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
    else:
        var symbol: String = "?"
        if action == "interact": symbol = "E"
        elif action == "ability_one": symbol = "1"
        elif action == "ability_two": symbol = "2"
        elif action == "ultimate": symbol = "U"
        draw_string(font, p + Vector2(-16,9)*factor, symbol, HORIZONTAL_ALIGNMENT_CENTER, 32.0*factor, maxi(15,int(25.0*factor)), ink)
