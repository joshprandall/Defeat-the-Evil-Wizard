class_name FloatingCombatText
extends Node2D

var value_text := ""
var tint := Color.WHITE

func setup(at: Vector2, text: String, color: Color) -> FloatingCombatText:
    global_position = at
    value_text = text
    tint = color
    z_index = 90
    return self

func _ready() -> void:
    var label := Label.new()
    label.text = value_text
    label.position = Vector2(-55, -24)
    label.size = Vector2(110, 42)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 22)
    label.add_theme_color_override("font_color", tint)
    label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    add_child(label)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "position:y", position.y - 54.0, 0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "modulate:a", 0.0, 0.62).set_delay(0.14)
    tween.chain().tween_callback(queue_free)
