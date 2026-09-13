class_name CinematicDirector
extends CanvasLayer

signal finished(sequence_id: String)
signal sfx_requested(id: String, volume_db: float, pitch: float)

var sequence_id: String = ""
var beats: Array[Dictionary] = []
var beat_index: int = 0
var overlay: Control
var art: CinematicArt
var chapter_label: Label
var speaker_label: Label
var body_label: Label
var progress_label: Label
var active: bool = false

func _ready() -> void:
    layer = 60
    process_mode = Node.PROCESS_MODE_ALWAYS
    _build()
    overlay.visible = false

func _build() -> void:
    overlay = Control.new()
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(overlay)

    var black: ColorRect = ColorRect.new()
    black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    black.color = Color("#020309")
    overlay.add_child(black)

    art = CinematicArt.new()
    art.position = Vector2(110,88)
    art.size = Vector2(1060,420)
    overlay.add_child(art)

    var frame: StyleBoxFlat = StyleBoxFlat.new()
    frame.bg_color = Color(0.02,0.025,0.04,0.48)
    frame.border_color = Color(0.50,0.54,0.64,0.42)
    frame.set_border_width_all(2)
    frame.corner_radius_top_left = 4
    frame.corner_radius_top_right = 4
    frame.corner_radius_bottom_left = 4
    frame.corner_radius_bottom_right = 4
    var panel: Panel = Panel.new()
    panel.position = Vector2(110,86)
    panel.size = Vector2(1060,424)
    panel.add_theme_stylebox_override("panel",frame)
    overlay.add_child(panel)

    chapter_label = Label.new()
    chapter_label.position = Vector2(130,28)
    chapter_label.size = Vector2(1020,40)
    chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    chapter_label.add_theme_font_size_override("font_size",18)
    chapter_label.add_theme_color_override("font_color",Color("#d8c691"))
    overlay.add_child(chapter_label)

    speaker_label = Label.new()
    speaker_label.position = Vector2(150,530)
    speaker_label.size = Vector2(980,26)
    speaker_label.add_theme_font_size_override("font_size",15)
    speaker_label.add_theme_color_override("font_color",Color("#e8c878"))
    overlay.add_child(speaker_label)

    body_label = Label.new()
    body_label.position = Vector2(150,562)
    body_label.size = Vector2(980,82)
    body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body_label.add_theme_font_size_override("font_size",20)
    body_label.add_theme_color_override("font_color",Color("#e6ebef"))
    overlay.add_child(body_label)

    progress_label = Label.new()
    progress_label.position = Vector2(150,660)
    progress_label.size = Vector2(980,28)
    progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    progress_label.text = "E / SPACE  CONTINUE"
    progress_label.add_theme_font_size_override("font_size",12)
    progress_label.add_theme_color_override("font_color",Color(0.70,0.75,0.80,0.70))
    overlay.add_child(progress_label)

func play_sequence(id: String, data: Array[Dictionary]) -> void:
    if data.is_empty():
        finished.emit(id)
        return
    sequence_id = id
    beats = data.duplicate(true)
    beat_index = 0
    active = true
    overlay.visible = true
    _show_beat()

func _show_beat() -> void:
    var beat: Dictionary = beats[beat_index]
    chapter_label.text = str(beat.get("chapter",""))
    speaker_label.text = str(beat.get("speaker","")).to_upper()
    body_label.text = str(beat.get("text",""))
    art.set_scene(str(beat.get("scene","prologue")),str(beat.get("hero","warrior")))
    progress_label.text = "E / SPACE  CONTINUE   //   %d / %d" % [beat_index+1,beats.size()]

func _advance() -> void:
    if not active:
        return
    sfx_requested.emit("cinematic_advance",-10.0,1.0)
    beat_index += 1
    if beat_index >= beats.size():
        active = false
        overlay.visible = false
        finished.emit(sequence_id)
        return
    _show_beat()

func _unhandled_input(event: InputEvent) -> void:
    if not active:
        return
    if event.is_action_pressed("interact") or event.is_action_pressed("jump") or event.is_action_pressed("attack"):
        _advance()
        get_viewport().set_input_as_handled()
