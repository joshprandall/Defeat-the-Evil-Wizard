class_name ConsoleInputBridge
extends Node

# The console shell and exported game are hosted together on the same origin.
# Only explicit messages from our own parent frame are forwarded as Input Map actions.
const CHANNEL := "evil-wizard-console/v1"
const ALLOWED := ["move_left", "move_right", "move_down", "jump", "attack", "heavy_attack", "dash", "interact", "ability_one", "ability_two", "ultimate"]
const REMAPPABLE := ["jump", "dash", "attack", "heavy_attack", "interact", "ability_one", "ability_two", "ultimate", "pause"]
const ALLOWED_KEYS := [32,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,4194305,4194311,4194312,4194313,4194314,4194325]
const ALLOWED_BUTTONS := [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
const ALLOWED_AXES := [4,5]
const CHAMPIONS := ["warrior", "mage", "rogue", "paladin", "archer", "barbarian", "fighter", "monk", "ranger", "cleric", "bard", "druid", "sorcerer", "warlock", "wizard"]

var _js_callback: JavaScriptObject
var _console_active := false
var _held: Dictionary = {} # pointer ID -> action; independent fingers/mouse buttons
var _reported_playing := false
var _has_reported_playing := false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    if not OS.has_feature("web"):
        return
    _js_callback = JavaScriptBridge.create_callback(_on_javascript_message)
    JavaScriptBridge.get_interface("window").__evilWizardInput = _js_callback
    JavaScriptBridge.eval("""
        (function () {
            if (window.__evilWizardConsoleListener) {
                window.removeEventListener('message', window.__evilWizardConsoleListener);
            }
            window.__evilWizardConsoleListener = function (event) {
                if (event.source !== window.parent || event.origin !== window.location.origin) return;
                if (!event.data || event.data.channel !== 'evil-wizard-console/v1') return;
                if (typeof window.__evilWizardInput === 'function') {
                    window.__evilWizardInput(JSON.stringify(event.data));
                }
            };
            window.addEventListener('message', window.__evilWizardConsoleListener);
            if (window.parent !== window) {
                window.parent.postMessage({type:'evil-wizard/hello'}, window.location.origin);
            }
        })();
    """)

func _process(_delta: float) -> void:
    if not _console_active or not OS.has_feature("web"):
        return
    var playing: bool = _game_is_playing()
    if _has_reported_playing and playing == _reported_playing:
        return
    _reported_playing = playing
    _has_reported_playing = true
    var literal: String = "true" if playing else "false"
    JavaScriptBridge.eval("window.parent.postMessage({type:'evil-wizard/state',playing:%s}, window.location.origin)" % literal)

func _exit_tree() -> void:
    _release_all()
    if OS.has_feature("web"):
        JavaScriptBridge.eval("""
            if (window.__evilWizardConsoleListener) {
                window.removeEventListener('message', window.__evilWizardConsoleListener);
                window.__evilWizardConsoleListener = null;
            }
            window.__evilWizardInput = null;
        """)

func _on_javascript_message(arguments: Array) -> void:
    if arguments.is_empty():
        return
    var parsed: Variant = JSON.parse_string(str(arguments[0]))
    if typeof(parsed) == TYPE_DICTIONARY:
        _receive_payload(parsed)

func _receive_payload(payload: Dictionary) -> void:
    if str(payload.get("channel", "")) != CHANNEL:
        return
    if str(payload.get("kind", "")) == "init":
        _console_active = true
        _has_reported_playing = false
        _disable_legacy_touch_overlay()
        if OS.has_feature("web"):
            JavaScriptBridge.eval("window.parent.postMessage({type:'evil-wizard/ready'}, window.location.origin)")
        return
    if not _console_active:
        return
    if str(payload.get("kind", "")) == "reset":
        _release_all()
        return
    if str(payload.get("kind", "")) == "settings":
        _apply_settings(payload)
        return
    if str(payload.get("kind", "")) == "controls":
        _apply_controls(payload)
        return
    if str(payload.get("kind", "")) == "start":
        _start_champion(str(payload.get("hero_class", "")))
        return
    if str(payload.get("kind", "")) != "button":
        return
    var action: String = str(payload.get("action", ""))
    if action == "pause":
        if bool(payload.get("pressed", false)):
            _toggle_pause()
        return
    if action not in ALLOWED or not InputMap.has_action(action):
        return
    var pointer: String = str(payload.get("pointer", ""))
    if pointer.is_empty() or pointer.length() > 80:
        return
    if bool(payload.get("pressed", false)):
        if not _game_is_playing():
            if action in ["interact", "jump", "attack"]:
                _advance_modal(action)
            return
        if _held.has(pointer):
            if _held[pointer] == action:
                return
            _release_pointer(pointer)
        var first_hold: bool = action not in _held.values()
        _held[pointer] = action
        if first_hold:
            _send_action(action, true)
    else:
        # A delayed release from another button must not cancel this action.
        if _held.get(pointer, "") == action:
            _release_pointer(pointer)

func _apply_settings(payload: Dictionary) -> void:
    var scene: Node = get_tree().current_scene
    if scene != null and scene.name == "Game":
        var difficulty: String = str(payload.get("difficulty", "adventurer"))
        if difficulty not in ["story","adventurer","legend"]:
            difficulty = "adventurer"
        scene.call("_on_difficulty_changed", difficulty)
        scene.set("camera_shake_enabled", bool(payload.get("camera_shake", true)))

    var volume_percent: float = clampf(float(payload.get("master_volume", 100.0)), 0.0, 100.0)
    var master_bus: int = AudioServer.get_bus_index("Master")
    if master_bus >= 0:
        AudioServer.set_bus_mute(master_bus, volume_percent <= 0.0)
        if volume_percent > 0.0:
            AudioServer.set_bus_volume_db(master_bus, linear_to_db(volume_percent / 100.0))


func _apply_controls(payload: Dictionary) -> void:
    var keyboard: Variant = payload.get("keyboard", {})
    if typeof(keyboard) == TYPE_DICTIONARY:
        for action: String in REMAPPABLE:
            if not keyboard.has(action):
                continue
            var key_code: int = int(keyboard[action])
            if key_code not in ALLOWED_KEYS:
                continue
            _replace_keyboard_event(action, key_code)

    var gamepad: Variant = payload.get("gamepad", {})
    if typeof(gamepad) == TYPE_DICTIONARY:
        for action: String in REMAPPABLE:
            if not gamepad.has(action):
                continue
            var binding: String = str(gamepad[action])
            _replace_gamepad_event(action, binding)


func _replace_keyboard_event(action: String, key_code: int) -> void:
    if not InputMap.has_action(action):
        return
    for event: InputEvent in InputMap.action_get_events(action).duplicate():
        if event is InputEventKey:
            InputMap.action_erase_event(action, event)
    var key_event: InputEventKey = InputEventKey.new()
    key_event.physical_keycode = key_code
    InputMap.action_add_event(action, key_event)


func _replace_gamepad_event(action: String, binding: String) -> void:
    if not InputMap.has_action(action):
        return
    for event: InputEvent in InputMap.action_get_events(action).duplicate():
        if event is InputEventJoypadButton or event is InputEventJoypadMotion:
            InputMap.action_erase_event(action, event)

    if binding.begins_with("button:"):
        var button_index: int = int(binding.trim_prefix("button:"))
        if button_index not in ALLOWED_BUTTONS:
            return
        var button_event: InputEventJoypadButton = InputEventJoypadButton.new()
        button_event.button_index = button_index
        InputMap.action_add_event(action, button_event)
        return

    if binding.begins_with("axis:"):
        var parts: PackedStringArray = binding.split(":")
        if parts.size() != 3:
            return
        var axis_index: int = int(parts[1])
        var direction: float = float(parts[2])
        if axis_index not in ALLOWED_AXES or absf(direction) != 1.0:
            return
        var axis_event: InputEventJoypadMotion = InputEventJoypadMotion.new()
        axis_event.axis = axis_index
        axis_event.axis_value = direction
        InputMap.action_add_event(action, axis_event)


func _advance_modal(action: String) -> void:
    var scene: Node = get_tree().current_scene
    if scene == null or scene.name != "Game":
        return
    var director: CinematicDirector = scene.get("cinema") as CinematicDirector
    if director != null and director.active:
        # These sequences listen for unhandled keyboard events. Advance one
        # beat per touch, instead of waiting for a physical keyboard on mobile.
        director.call("_advance")
        return
    var game_hud: GameHUD = scene.get("hud") as GameHUD
    if game_hud != null and game_hud.dialogue_panel.visible and action == "interact":
        _send_action("interact", true)
        _send_action("interact", false)

func _send_action(action: String, pressed: bool) -> void:
    if pressed:
        Input.action_press(action)
    else:
        Input.action_release(action)
    # In addition to polling, deliver an event for dialogue and other UI
    # handlers that rely on _input/_unhandled_input instead of Input.is_action_pressed.
    var event: InputEventAction = InputEventAction.new()
    event.action = action
    event.pressed = pressed
    Input.parse_input_event(event)

func _start_champion(champion: String) -> void:
    if champion not in CHAMPIONS:
        return
    var scene: Node = get_tree().current_scene
    if scene == null or scene.name != "Game":
        return
    var game_hud: GameHUD = scene.get("hud") as GameHUD
    if game_hud == null or not game_hud.title_overlay.visible:
        return
    game_hud.start_requested.emit(champion)

func _game_is_playing() -> bool:
    var scene: Node = get_tree().current_scene
    if scene == null or scene.get("player") == null or get_tree().paused:
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

func _release_pointer(pointer: String) -> void:
    if not _held.has(pointer):
        return
    var action: String = str(_held[pointer])
    _held.erase(pointer)
    if action not in _held.values():
        _send_action(action, false)

func _release_all() -> void:
    for action: Variant in _held.values().duplicate():
        if InputMap.has_action(str(action)):
            _send_action(str(action), false)
    _held.clear()

func _toggle_pause() -> void:
    var scene: Node = get_tree().current_scene
    if scene == null:
        return
    if scene.name == "Game":
        var game_hud: GameHUD = scene.get("hud") as GameHUD
        if game_hud != null and not game_hud.title_overlay.visible and not game_hud.victory_overlay.visible:
            game_hud.pause_toggled.emit()
    elif scene.name == "MovementLab":
        _release_all()
        get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _disable_legacy_touch_overlay() -> void:
    var scene: Node = get_tree().current_scene
    if scene == null:
        return
    var old_controls: Control = scene.get_node_or_null("MobileTouchLayer/MobileTouchControls") as Control
    if old_controls != null:
        old_controls.call("_release_all")
        old_controls.set_process(false)
        old_controls.set_process_input(false)
        old_controls.visible = false
        # The standalone game keeps its own controls. In the framed game,
        # restore click/touch emulation for the built-in menus.
        if OS.has_feature("web"):
            Input.set_emulate_mouse_from_touch(true)
