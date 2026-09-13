class_name HitFlash
extends Node2D

var color := Color.WHITE
var radius := 12.0

func setup(at: Vector2, tint: Color) -> HitFlash:
    global_position = at
    color = tint
    z_index = 50
    return self

func _ready() -> void:
    queue_redraw()
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "scale", Vector2(2.8, 2.8), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "modulate:a", 0.0, 0.20)
    tween.tween_property(self, "rotation", 0.32, 0.20)
    tween.chain().tween_callback(queue_free)

func _draw() -> void:
    draw_circle(Vector2.ZERO, radius, Color(color.r,color.g,color.b,0.70))
    draw_arc(Vector2.ZERO, radius + 8.0, 0, TAU, 24, Color(color.r,color.g,color.b,0.48), 2.0)
    for i in 10:
        var a := TAU * float(i) / 10.0
        var start := Vector2.from_angle(a) * 9.0
        var finish := Vector2.from_angle(a) * (27.0 + (i%3)*5.0)
        draw_line(start, finish, color, 2.5)
