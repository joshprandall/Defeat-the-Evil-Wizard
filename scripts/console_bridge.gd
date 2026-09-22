class_name ConsoleInputBridge
extends Node

# The console shell and exported game are hosted together on the same origin.
# Only explicit messages from our own parent frame are forwarded as Input Map actions.
const CHANNEL := "evil-wizard-console/v1"
const ALLOWED := ["move_left", "move_right", "move_down", "jump", "attack", "heavy_attack", "dash", "interact", "ability_one", "ability_two", "ultimate"]

var _js_callback: JavaScriptObject
var _console_active := false
var _held: Dictionary = {} # pointer ID -> action; independent fingers/mouse buttons

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
        _disable_legacy_touch_overlay()
        if OS.has_feature("web"):
            JavaScriptBridge.eval("window.parent.postMessage({type:'evil-wizard/ready'}, window.location.origin)")
        return
    if not _console_active:
        return
    if str(payload.get("kind", "")) == "reset":
        _release_all()
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
            return
        if _held.has(pointer):
            if _held[pointer] == action:
                return
            _release_pointer(pointer)
        _held[pointer] = action
        Input.action_press(action)
    else:
        # A delayed release from another button must not cancel this action.
        if _held.get(pointer, "") == action:
            _release_pointer(pointer)

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
    for held_action: Variant in _held.values():
        if held_action == action:
            return
    Input.action_release(action)

func _release_all() -> void:
    for action: Variant in _held.values():
        Input.action_release(str(action))
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
        # The standalone game can keep its own controls, but the framed game
        # must restore click/touch emulation for its champion/menu UI.
        if OS.has_feature("web"):
            Input.set_emulate_mouse_from_touch(true)
